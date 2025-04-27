import threading
import json
from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.events.ticked_issued_event import TicketIssuedEvent
import logging
import json
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..infrastructure.database.notification_repository import NotificationRepository

setup_logging()
app = FastAPI()
notifications = []

logger = logging.getLogger(__name__)
repo = NotificationRepository()

def handle_seat_unavailable(body: dict):
    logger.info(f"[Notification] Received seats.unavailable: {body}")  # :contentReference[oaicite:16]{index=16}
    repo.add("seats.unavailable", body)

def handle_payment_failed(body: dict):
    logger.info(f"[Notification] Received payments.failed: {body}")  # :contentReference[oaicite:17]{index=17}
    repo.add("payments.failed", body)

def handle_ticket_issued(body: dict):
    logger.info(f"[Notification] Received tickets.issued: {body}")  # :contentReference[oaicite:18]{index=18}
    repo.add("tickets.issued", body)

@app.on_event("startup")
def startup():
    # seats.unavailable
    threading.Thread(target=consume, args=(SeatAllocatedEvent.UNAVAILABLE, handle_seat_unavailable), daemon=True).start()
    # payments.failed
    threading.Thread(target=consume, args=(PaymentFailedEvent.NAME, handle_payment_failed), daemon=True).start()
    # tickets.issued
    threading.Thread(target=consume, args=(TicketIssuedEvent.NAME, handle_ticket_issued), daemon=True).start()

@app.get("/status")
def status():
    # zwróć ostatnie powiadomienia
    return notifications[-5:]
