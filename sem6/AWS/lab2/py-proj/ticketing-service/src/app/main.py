import threading
import json
from fastapi import FastAPI

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.ticked_issued_event import TicketIssuedEvent
from ..domain.usecases.issue_ticket import IssueTicketUseCase

import logging
from ..infrastructure.database.ticket_repository import TicketRepository

setup_logging()
app = FastAPI()
last_event = {}

logger = logging.getLogger(__name__)

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(PaymentSucceededEvent.NAME, handle_payment_succeeded),
        daemon=True
    ).start()

def handle_payment_succeeded(body: dict):
    logger.info(f"[Ticketing] Received payments.succeeded: {body}")  # :contentReference[oaicite:10]{index=10}
    uc = IssueTicketUseCase()
    ticket = uc.execute(body)

    # Zapis do DB
    repo = TicketRepository()
    repo.add(
        reservation_id=ticket["reservation_id"],
        ticket_id=ticket["ticket_id"],
        issued_at=ticket["issued_at"]
    )

    # Publikacja eventu
    logger.info(f"[Ticketing] Publishing tickets.issued: {ticket}")  # :contentReference[oaicite:11]{index=11}
    producer.publish(routing_key=TicketIssuedEvent.NAME, message=ticket)

@app.get("/status")
def status():
    return last_event
