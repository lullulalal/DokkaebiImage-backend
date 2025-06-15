from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from io import BytesIO
import zipfile

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/colorTransfer")
async def color_transfer(request: Request):
    received_zip = await request.body()
    print(f"Received ZIP size: {len(received_zip)} bytes")

    try:
        zip_stream = BytesIO(received_zip)
        with zipfile.ZipFile(zip_stream, 'r') as zipf:
            print("ZIP contains the following files:")
            for name in zipf.namelist():
                print(f" - {name}")
    except Exception as e:
        print("Failed to read ZIP contents:", e)

    buffer = BytesIO()
    with zipfile.ZipFile(buffer, "w", zipfile.ZIP_DEFLATED) as zipf:
        zipf.writestr("dummy.txt", "This is a dummy response zip file.")

    buffer.seek(0)
    return StreamingResponse(
        buffer,
        media_type="application/zip",
        headers={"Content-Disposition": "attachment; filename=result.zip"}
    )
