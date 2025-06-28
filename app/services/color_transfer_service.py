import numpy as np
import cv2
from services.common.interface_service import InterfaceService

class ColorTransferService(InterfaceService):

	def __init__(self, ref_bytes, targets_bytes, targets_fname):
		super().__init__(targets_fname)
		self.reference_image = self._byte_to_cvimage(ref_bytes)

		for i in range(len(targets_bytes)): 
			self.target_images.append(self._byte_to_cvimage(targets_bytes[i]))

	def _byte_to_cvimage(self, img_bytes: bytes) -> np.ndarray:
		img_arr = np.frombuffer(img_bytes, np.uint8)
		img_cv = cv2.imdecode(img_arr, cv2.IMREAD_COLOR) 
		return cv2.cvtColor(img_cv,cv2.COLOR_BGR2LAB)
		
	def _get_mean_and_std(self, x: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
		x_mean, x_std = cv2.meanStdDev(x)
		return x_mean.flatten(), x_std.flatten()  # shape: (3,)

	def processing(self):
		ref_mean, ref_std = self._get_mean_and_std(self.reference_image)
		ref_mean = ref_mean.reshape(1, 1, 3)
		ref_std = ref_std.reshape(1, 1, 3)

		for n in range(len(self.target_images)):
			target = self.target_images[n]
			target_mean, target_std = self._get_mean_and_std(target)
			target_mean = target_mean.reshape(1, 1, 3)
			target_std = target_std.reshape(1, 1, 3)

			adjusted = (((target - target_mean) / target_std) * ref_std) + ref_mean
			adjusted = np.clip(np.round(adjusted), 0, 255).astype(np.uint8)

			self.target_images[n] = cv2.cvtColor(adjusted, cv2.COLOR_LAB2BGR)