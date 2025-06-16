# app/routes/color_transfer.py

from fastapi import APIRouter, Request
from fastapi.responses import StreamingResponse

from services.color_transfer_service import ColorTransferService

router = APIRouter()

@router.post("/colorTransfer")
async def color_transfer(request: Request):
    received_zip = await request.body()
    if not received_zip:
        return {"error": "No file uploaded"}
    
    color_transfer_service = ColorTransferService(received_zip)
    color_transfer_service.color_transfer()
    result_zip = color_transfer_service.export_images_to_zip()

    return StreamingResponse(
        result_zip,
        media_type="application/zip",
        headers={"Content-Disposition": "attachment; filename=result.zip"}
    )
