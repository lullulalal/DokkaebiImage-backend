# app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes import color_transfer
from .routes import noise_remover

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://lullulalal.github.io",  # ✅ GitHub Pages 도메인
    ],
    allow_origin_regex=r"http://localhost:\d+",          # ✅ 포트가 바뀌는 로컬 개발환경
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello from DokkaebiImage backend!"}

app.include_router(color_transfer.router)
app.include_router(noise_remover.router)