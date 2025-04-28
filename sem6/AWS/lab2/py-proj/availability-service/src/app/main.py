# availability-service/src/app/main.py

import threading
import logging

from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.reservation_created_event import ReservationCreatedEvent
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.usecases.allocate_seat import AllocateSeatUseCase
from ..infrastructure.database.seat_repository import SeatRepository
from ..infrastructure.database.session import SessionLocal  # tworzy tabele

setup_logging()
logger = logging.getLogger(__name__)
app = FastAPI(title="Availability Service")

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(ReservationCreatedEvent.NAME, handle_reservation_created),
        daemon=True
    ).start()
    logger.info(f"[Availability] Started consumer for '{ReservationCreatedEvent.NAME}'")

def handle_reservation_created(body: dict):
    logger.info(f"[Availability] Received '{ReservationCreatedEvent.NAME}': {body}")
    uc = AllocateSeatUseCase()
    result = uc.execute(body)  # SeatReservation

    # Poprawka: używamy result.status, bo domenowa klasa ma pole status, nie allocated
    if result.status == "RESERVED":
        event_key = SeatAllocatedEvent.NAME
    else:
        event_key = SeatAllocatedEvent.UNAVAILABLE

    event_body = result.to_dict()
    logger.info(f"[Availability] Publishing '{event_key}': {event_body}")
    producer.publish(routing_key=event_key, message=event_body)

    # Zapis domenowego obiektu do bazy
    repo = SeatRepository()
    repo.add(result)

@app.get("/seat_reservations")
def list_reservations():
    logger.info("[Availability][API] GET /seat_reservations")
    items = SeatRepository().list_all()
    return {"seat_reservations": [item.__dict__ for item in items]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.app.main:app", host="127.0.0.1", port=8001, log_level="info")
