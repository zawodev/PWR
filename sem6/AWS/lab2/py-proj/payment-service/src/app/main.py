import threading
import logging

from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.usecases.process_payment import ProcessPaymentUseCase
from ..infrastructure.database.payment_repository import PaymentRepository
from ..infrastructure.database.session import SessionLocal

setup_logging()
logger = logging.getLogger(__name__)
app = FastAPI(title="Payment Service")

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(SeatAllocatedEvent.NAME, handle_seat_allocated),
        daemon=True
    ).start()
    logger.info(f"[Payment] Started consumer for '{SeatAllocatedEvent.NAME}'")

def handle_seat_allocated(body: dict):
    logger.info(f"[Payment] Received '{SeatAllocatedEvent.NAME}': {body}")
    uc = ProcessPaymentUseCase()
    result = uc.execute(body)  # result to Payment

    # Zapis do bazy
    repo = PaymentRepository()
    repo.add(result)

    # Wybór eventu
    event_key = (
        PaymentSucceededEvent.NAME if result.status == "SUCCEEDED"
        else PaymentFailedEvent.NAME
    )
    event_body = result.to_dict()
    logger.info(f"[Payment] Publishing '{event_key}': {event_body}")
    producer.publish(routing_key=event_key, message=event_body)

@app.get("/payments")
def list_payments():
    logger.info("[Payment][API] GET /payments")
    items = PaymentRepository().list_all()
    return {"payments": [item.__dict__ for item in items]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.app.main:app", host="127.0.0.1", port=8002, log_level="info")
