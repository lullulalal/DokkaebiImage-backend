# app/routes/color_transfer.py

from fastapi import APIRouter
from fastapi import File, UploadFile
from ..services.color_transfer_service import ColorTransferService
from typing import List
from fastapi.responses import JSONResponse

router = APIRouter()

@router.post("/colorTransfer")
async def color_transfer(
    reference: UploadFile = File(...),
    targets: List[UploadFile] = File(...),
):
    # Reference image
    ref_bytes = await reference.read()

    # Target images
    targets_bytes = []
    targets_fname = []

    for t in targets:
        img_bytes = await t.read()
        targets_bytes.append(img_bytes)
        targets_fname.append(t.filename)
    
    color_transfer_service = ColorTransferService(ref_bytes, targets_bytes, targets_fname)
    color_transfer_service.processing()
    result = color_transfer_service.export_results_base64()

    return JSONResponse(content=result)
