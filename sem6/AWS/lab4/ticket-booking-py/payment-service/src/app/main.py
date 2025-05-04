import threading
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer

from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.commands.process_payment_handler import ProcessPaymentCommand, handle_process_payment

from ..app.controllers.payment_controller import router as payment_router

# Configure logging
setup_logging()
logger = logging.getLogger(__name__)

app = FastAPI(title="Payment Service")
app.include_router(payment_router, prefix="/payments")

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
    def _on_seat_allocated(body):
        logger.info(f"[Payment][EVENT] Received '{SeatAllocatedEvent.NAME}': {body}")
        cmd = ProcessPaymentCommand(
            booking_id=body["bookingId"],
            amount=body.get("amount", 0),
            currency=body.get("currency", "PLN")
        )
        result = handle_process_payment(cmd)
        key = PaymentSucceededEvent.NAME if result["status"] == "SUCCEEDED" else PaymentFailedEvent.NAME
        logger.info(f"[Payment][EVENT] Publishing '{key}': {result}")
        producer.publish(routing_key=key, message=result)

    threading.Thread(
        target=consume,
        args=(SeatAllocatedEvent.NAME, _on_seat_allocated),
        daemon=True
    ).start()
    logger.info(f"[Payment] Consumer for '{SeatAllocatedEvent.NAME}' started")
