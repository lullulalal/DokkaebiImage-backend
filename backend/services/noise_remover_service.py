import numpy as np
import cv2
import os
from io import BytesIO
import zipfile
import base64
import ctypes
import platform

if platform.system() == "Windows":
    lib_path = os.path.join("services", "3rd_party_libs", "nr_libbm3d.dll")
else:
    lib_path = os.path.join("services", "3rd_party_libs", "nr_libbm3d.so")

# 라이브러리 로드
bm3d = ctypes.CDLL(lib_path)

bm3d.run_bm3d_yuv_memory.argtypes = [
	ctypes.POINTER(ctypes.c_ubyte),
	ctypes.POINTER(ctypes.c_ubyte),
	ctypes.c_int, ctypes.c_int, ctypes.c_int
]
bm3d.run_bm3d_yuv_memory.restype = ctypes.c_int

class NoiseRemoverService():

	def __init__(self, targets_bytes, targets_fname):
		self.targets_bytes = targets_bytes
		self.targets_fname = targets_fname
		self.target_cvimages = []

	def processing(self) -> np.ndarray:
		for n in range(len(self.targets_bytes)):
			img_arr = np.frombuffer(self.targets_bytes[n], np.uint8)
			img_cv = cv2.imdecode(img_arr, cv2.IMREAD_UNCHANGED)

			if img_cv is None:
				raise ValueError("Invalid image data")

			h, w = img_cv.shape[:2]

			# gray scale image
			if len(img_cv.shape) == 2 or (len(img_cv.shape) == 3 and img_cv.shape[2] == 1):
				y = img_cv if len(img_cv.shape) == 2 else img_cv[:, :, 0]
				input_buf = y.copy().astype(np.uint8)

				output_buf = np.empty_like(input_buf)
				input_ptr = input_buf.ctypes.data_as(ctypes.POINTER(ctypes.c_ubyte))
				output_ptr = output_buf.ctypes.data_as(ctypes.POINTER(ctypes.c_ubyte))

				bm3d.run_bm3d_yuv_memory(input_ptr, output_ptr, w, h, 1)

				result_img = output_buf

			else:
				yuv_img = cv2.cvtColor(img_cv, cv2.COLOR_BGR2YCrCb)

				y = yuv_img[:, :, 0]
				cr = yuv_img[:, :, 1]
				cb = yuv_img[:, :, 2]

				input_buf = np.concatenate([
					y.flatten(),
					cr.flatten(),
					cb.flatten()
				]).astype(np.uint8)

				output_buf = np.empty_like(input_buf)

				input_ptr = input_buf.ctypes.data_as(ctypes.POINTER(ctypes.c_ubyte))
				output_ptr = output_buf.ctypes.data_as(ctypes.POINTER(ctypes.c_ubyte))

				bm3d.run_bm3d_yuv_memory(input_ptr, output_ptr, w, h, 3)

				y_out = output_buf[0:w*h].reshape((h, w))
				cr_out = output_buf[w*h:2*w*h].reshape((h, w))
				cb_out = output_buf[2*w*h:3*w*h].reshape((h, w))

				yuv_out = np.stack([y_out, cr_out, cb_out], axis=2).astype(np.uint8)
				result_img = cv2.cvtColor(yuv_out, cv2.COLOR_YCrCb2BGR)

			self.target_cvimages.append(result_img)

	def export_results_base64(self) -> dict:
		image_entries = []
		zip_buffer = BytesIO()

		with zipfile.ZipFile(zip_buffer, 'w') as zipf:
			for n, img in enumerate(self.target_cvimages):
				name, ext = os.path.splitext(os.path.basename(self.targets_fname[n]))
				success, encoded_img = cv2.imencode(ext, img)
				if success:
					img_bytes = encoded_img.tobytes()

					zipf.writestr(f'result/{name}{ext}', img_bytes)

					image_entries.append({
						"filename": f"{name}{ext}",
						"data": base64.b64encode(img_bytes).decode('utf-8')
					})

		zip_buffer.seek(0)
		zip_base64 = base64.b64encode(zip_buffer.read()).decode('utf-8')

		return {
			"images": image_entries,
			"zip": zip_base64
		}