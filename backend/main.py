# app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import color_transfer

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(color_transfer.router)
