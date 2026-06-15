from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import FRONTEND_ORIGIN
from app.routers.notifications import router as notifications_router
from app.sqs_worker import start_worker, stop_worker


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Launch the SQS polling thread on startup
    worker_thread = start_worker()
    yield
    stop_worker()


app = FastAPI(title="Notification Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[FRONTEND_ORIGIN] if FRONTEND_ORIGIN != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(notifications_router)
