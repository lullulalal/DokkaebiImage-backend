# app/routes/noise_remover.py

from fastapi import APIRouter
from fastapi import File, UploadFile
from ..services.noise_remover_service import NoiseRemoverService
from typing import List
from fastapi.responses import JSONResponse

router = APIRouter()

@router.post("/noiseRemover")
async def color_transfer(
    targets: List[UploadFile] = File(...),
):
    # Target images
    targets_bytes = []
    targets_fname = []

    for t in targets:
        img_bytes = await t.read()
        targets_bytes.append(img_bytes)
        targets_fname.append(t.filename)
    
    color_transfer_service = NoiseRemoverService(targets_bytes, targets_fname)
    color_transfer_service.processing()
    result = color_transfer_service.export_results_base64()

    return JSONResponse(content=result)
