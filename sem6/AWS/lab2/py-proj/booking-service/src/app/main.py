from fastapi import FastAPI
from ..app.controllers.booking_controller import router as reservation_router
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings

setup_logging()

app = FastAPI(title="Booking Service")
app.include_router(reservation_router, prefix="/reservations")

from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "ok"}
