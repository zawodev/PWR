import threading
from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.reservation_created_event import ReservationCreatedEvent
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.usecases.allocate_seat import AllocateSeatUseCase

setup_logging()
app = FastAPI()
last_event = {}

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
    uc = AllocateSeatUseCase()
    result = uc.execute(body)
    # Wybór eventu do publikacji
    routing = (
        SeatAllocatedEvent.NAME
        if result["allocated"]
        else SeatAllocatedEvent.UNAVAILABLE
    )
    producer.publish(routing_key=routing, message=result)
    last_event.update(result)

@app.get("/status")
def status():
    return last_event
