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

setup_logging()
app = FastAPI()
last_event = {}

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(SeatAllocatedEvent.NAME, handle_seat_allocated),
        daemon=True
    ).start()

def handle_seat_allocated(body: dict):
    uc = ProcessPaymentUseCase()
    result = uc.execute(body)
    # wybór eventu do publikacji
    if result["succeeded"]:
        producer.publish(
            routing_key=PaymentSucceededEvent.NAME,
            message=result
        )
    else:
        producer.publish(
            routing_key=PaymentFailedEvent.NAME,
            message=result
        )
    last_event.update(result)

@app.get("/status")
def status():
    return last_event
