import numpy as np
import cv2
import os
from io import BytesIO
import zipfile
import base64

class ColorTransferService:

	def __init__(self, ref_bytes, targets_bytes, targets_fname):
		self.reference_cvimage = None
		self.target_cvimages = []
		self.target_cvimages_fpath = []

		self.reference_cvimage = self._byte_to_cvimage(ref_bytes)

		for i in range(len(targets_bytes)): 
			self.target_cvimages.append(self._byte_to_cvimage(targets_bytes[i]))
			self.target_cvimages_fpath.append(targets_fname[i])

	def _byte_to_cvimage(self, img_bytes: bytes) -> np.ndarray:
		img_arr = np.frombuffer(img_bytes, np.uint8)
		img_cv = cv2.imdecode(img_arr, cv2.IMREAD_COLOR) 
		return cv2.cvtColor(img_cv,cv2.COLOR_BGR2LAB)
		
	def _get_mean_and_std(self, x: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
		x_mean, x_std = cv2.meanStdDev(x)
		x_mean = np.hstack(np.around(x_mean,2))
		x_std = np.hstack(np.around(x_std,2))
		return x_mean, x_std

	def color_transfer(self):
		ref_mean, ref_std = self._get_mean_and_std(self.reference_cvimage)

		for n in range(len(self.target_cvimages)):

			target_mean, target_std = self._get_mean_and_std(self.target_cvimages[n])

			height, width, channel = self.target_cvimages[n].shape
			for i in range(0,height):
				for j in range(0,width):
					for k in range(0,channel):
						x = self.target_cvimages[n][i,j,k]
						x = ((x-target_mean[k])*(ref_std[k]/target_std[k]))+ref_mean[k]
						x = round(x)
						x = 0 if x<0 else x
						x = 255 if x>255 else x
						self.target_cvimages[n][i,j,k] = x

			self.target_cvimages[n] = cv2.cvtColor(self.target_cvimages[n], cv2.COLOR_LAB2BGR)

	def export_images_and_zip_base64(self) -> dict:
		image_entries = []

		zip_buffer = BytesIO()
		with zipfile.ZipFile(zip_buffer, 'w') as zipf:
			for n, img in enumerate(self.target_cvimages):
				name, ext = os.path.splitext(os.path.basename(self.target_cvimages_fpath[n]))
				success, encoded_img = cv2.imencode(ext, img)
				if success:
					img_bytes = encoded_img.tobytes()

					# Add to zip
					zipf.writestr(f'result/{name}{ext}', img_bytes)

					# Add to images list as base64
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