import threading
import json
from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.usecases.process_payment import ProcessPaymentUseCase
import logging
from ..infrastructure.database.payment_repository import PaymentRepository

setup_logging()
app = FastAPI()
last_event = {}

logger = logging.getLogger(__name__)

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(SeatAllocatedEvent.NAME, handle_seat_allocated),
        daemon=True
    ).start()

def handle_seat_allocated(body: dict):
    logger.info(f"[Payment] Received seats.allocated: {body}")  # :contentReference[oaicite:4]{index=4}
    uc = ProcessPaymentUseCase()
    result = uc.execute(body)

    # Zapis do DB
    repo = PaymentRepository()
    repo.add(
        reservation_id=result["reservation_id"],
        succeeded=result["succeeded"],
        amount=result.get("amount", 0),
        failure_reason=result.get("failure_reason", "")
    )

    # Publikacja eventu
    event_key = (
        PaymentSucceededEvent.NAME if result["succeeded"]
        else PaymentFailedEvent.NAME
    )
    logger.info(f"[Payment] Publishing {event_key}: {result}")  # :contentReference[oaicite:5]{index=5}
    producer.publish(routing_key=event_key, message=result)

@app.get("/status")
def status():
    return last_event
