import numpy as np
import cv2
import ctypes
from services.common.interface_service import InterfaceService
from services.common.load_third_party_lib import load_third_party_lib

class NoiseRemoverService(InterfaceService):

	def __init__(self, targets_bytes, targets_fname):
		self.targets_bytes = targets_bytes
		self.bm3d = load_third_party_lib("bm3d", "run_bm3d_yuv_memory")
		super().__init__(targets_fname)

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

				self.bm3d(input_ptr, output_ptr, w, h, 1)

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

				self.bm3d(input_ptr, output_ptr, w, h, 3)

				y_out = output_buf[0:w*h].reshape((h, w))
				cr_out = output_buf[w*h:2*w*h].reshape((h, w))
				cb_out = output_buf[2*w*h:3*w*h].reshape((h, w))

				yuv_out = np.stack([y_out, cr_out, cb_out], axis=2).astype(np.uint8)
				result_img = cv2.cvtColor(yuv_out, cv2.COLOR_YCrCb2BGR)

			self.target_images.append(result_img)