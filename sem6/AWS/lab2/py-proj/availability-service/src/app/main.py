import threading
from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..domain.events.reservation_created_event import ReservationCreatedEvent
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.usecases.allocate_seat import AllocateSeatUseCase
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..infrastructure.database.availability_repository import SeatRepository
import logging

setup_logging()
app = FastAPI()
last_event = {}
logger = logging.getLogger(__name__)

@app.on_event("startup")
def startup():
    # Teraz subskrybujemy reservations.created
    threading.Thread(
        target=consume,
        args=(
            ReservationCreatedEvent.NAME,  # routing key
            handle_reservation_created      # callback
        ),
        daemon=True
    ).start()

def handle_reservation_created(body: dict):
    logger.info(f"[Availability] Handling ReservationCreated: {body}")
    uc = AllocateSeatUseCase()
    result = uc.execute(body)
    event_key = SeatAllocatedEvent.NAME if result["allocated"] else SeatAllocatedEvent.UNAVAILABLE
    logger.info(f"[Availability] Publishing '{event_key}': {result}")
    producer.publish(routing_key=event_key, message=result)
    repo = SeatRepository()
    repo.add(body["id"], result["allocated"], result.get("seat_number"))
    last_event.update(result)

@app.get("/status")
def status():
    return last_event


