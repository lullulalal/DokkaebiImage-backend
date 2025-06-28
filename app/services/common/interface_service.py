from abc import ABC, abstractmethod
import numpy as np
import zipfile
import base64
import cv2
import os
from io import BytesIO

class InterfaceService(ABC):

	def __init__(self, target_images_fname):
		self.target_images_fname = target_images_fname
		self.target_images = []

	@abstractmethod
	def processing(self) -> np.ndarray:
		pass

	def export_results_base64(self) -> dict:
		image_entries = []
		zip_buffer = BytesIO()

		with zipfile.ZipFile(zip_buffer, 'w') as zipf:
			for n, img in enumerate(self.target_images):
				name, ext = os.path.splitext(os.path.basename(self.target_images_fname[n]))
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