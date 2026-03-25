from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import DATABASE_URL, FRONTEND_ORIGIN, UPLOAD_DIR, DB_PATH, S3_BUCKET
from app.db import Base, engine
from app.routers.media import router as media_router
from app.routers.messages import router as messages_router

app = FastAPI(title="Simple Group Chat API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[FRONTEND_ORIGIN] if FRONTEND_ORIGIN != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    if not S3_BUCKET:
        UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    if DATABASE_URL.startswith("sqlite"):
        DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    Base.metadata.create_all(bind=engine)


@app.get("/api/health")
def health():
    return {"status": "ok"}


app.include_router(messages_router)
app.include_router(media_router)
