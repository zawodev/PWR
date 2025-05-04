import threading
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer

from ..domain.events.reservation_created_event import ReservationCreatedEvent
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.seat_unavailable_event import SeatUnavailableEvent
from ..domain.commands.allocate_seat_handler import AllocateSeatCommand, handle_allocate_seat

from ..app.controllers.availability_controller import router as availability_router

# Configure logging
setup_logging()
logger = logging.getLogger(__name__)

app = FastAPI(title="Availability Service")
app.include_router(availability_router, prefix="/seat_reservations")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.on_event("startup")
def startup():
    # Subskrybujemy event z Booking Service
    def _on_reservation(body):
        logger.info(f"[Availability][EVENT] Received '{ReservationCreatedEvent.NAME}': {body}")
        cmd = AllocateSeatCommand(
            booking_id=body["bookingId"],
            match_id=body["matchId"],
            seats=body["seats"]
        )
        result = handle_allocate_seat(cmd)
        key = SeatAllocatedEvent.NAME if result["status"] == "RESERVED" else SeatUnavailableEvent.NAME
        logger.info(f"[Availability][EVENT] Publishing '{key}': {result}")
        producer.publish(routing_key=key, message=result)

    threading.Thread(
        target=consume,
        args=(ReservationCreatedEvent.NAME, _on_reservation),
        daemon=True
    ).start()
    logger.info(f"[Availability] Consumer for '{ReservationCreatedEvent.NAME}' started")
