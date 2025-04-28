import threading
import logging

from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.events.ticket_issued_event import TicketIssuedEvent
from ..domain.usecases.send_notification import SendNotificationUseCase
from ..infrastructure.database.notification_repository import NotificationRepository
from ..infrastructure.database.session import SessionLocal

setup_logging()
logger = logging.getLogger(__name__)
app = FastAPI(title="Notification Service")

@app.on_event("startup")
def startup():
    # seats.unavailable → traktujemy jako PENDING notification
    threading.Thread(
        target=consume,
        args=(SeatAllocatedEvent.UNAVAILABLE, handle_unavailable),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{SeatAllocatedEvent.UNAVAILABLE}' started")

    threading.Thread(
        target=consume,
        args=(PaymentFailedEvent.NAME, handle_failed),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{PaymentFailedEvent.NAME}' started")

    threading.Thread(
        target=consume,
        args=(TicketIssuedEvent.NAME, handle_issued),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{TicketIssuedEvent.NAME}' started")

def handle_unavailable(body: dict):
    logger.info(f"[Notification] Received '{SeatAllocatedEvent.UNAVAILABLE}': {body}")
    uc = SendNotificationUseCase()
    result = uc.execute(body, channel="SYSTEM", status="PENDING")
    producer_response = result.to_dict()
    logger.info(f"[Notification] Saved notification: {producer_response}")

def handle_failed(body: dict):
    logger.info(f"[Notification] Received '{PaymentFailedEvent.NAME}': {body}")
    uc = SendNotificationUseCase()
    result = uc.execute(body, channel="SYSTEM", status="PENDING")
    logger.info(f"[Notification] Saved notification: {result.to_dict()}")

def handle_issued(body: dict):
    logger.info(f"[Notification] Received '{TicketIssuedEvent.NAME}': {body}")
    uc = SendNotificationUseCase()
    result = uc.execute(body, channel="EMAIL", status="SENT")
    logger.info(f"[Notification] Saved notification: {result.to_dict()}")

@app.get("/notifications")
def list_notifications():
    logger.info("[Notification][API] GET /notifications")
    items = NotificationRepository().list_all()
    return {"notifications": [item.__dict__ for item in items]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.app.main:app", host="127.0.0.1", port=8004, log_level="info")
