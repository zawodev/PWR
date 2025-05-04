import threading
import logging
import random

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer

from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.ticket_issued_event import TicketIssuedEvent
from ..domain.commands.issue_ticket_handler import IssueTicketCommand, handle_issue_ticket

from ..app.controllers.ticketing_controller import router as ticket_router

# Configure logging
setup_logging()
logger = logging.getLogger(__name__)

app = FastAPI(title="Ticketing Service")
app.include_router(ticket_router, prefix="/tickets")

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
    def _on_payment_succeeded(body):
        logger.info(f"[Ticketing][EVENT] Received '{PaymentSucceededEvent.NAME}': {body}")
        cmd = IssueTicketCommand(
            booking_id=body["bookingId"],
            qr_code=f"QR{body['bookingId'][:8]}{body['bookingId'][-8:]}",
            valid_minutes=random.randint(5, 120)
        )
        result = handle_issue_ticket(cmd)
        logger.info(f"[Ticketing][EVENT] Publishing '{TicketIssuedEvent.NAME}': {result}")
        producer.publish(routing_key=TicketIssuedEvent.NAME, message=result)

    threading.Thread(
        target=consume,
        args=(PaymentSucceededEvent.NAME, _on_payment_succeeded),
        daemon=True
    ).start()
    logger.info(f"[Ticketing] Consumer for '{PaymentSucceededEvent.NAME}' started")
