import threading
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer

from ..domain.events.seat_unavailable_event import SeatUnavailableEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.events.ticket_issued_event import TicketIssuedEvent

from ..domain.commands.send_notification_handler import handle_send_notification, SendNotificationCommand
from ..app.controllers.notification_controller import router as notification_router

setup_logging()
logger = logging.getLogger(__name__)
app = FastAPI(title="Notification Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(notification_router, prefix="/notifications")

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(
            SeatUnavailableEvent.NAME,
            lambda body: handle_event(body, "SYSTEM", "PENDING", SeatUnavailableEvent.NAME)
        ),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{SeatUnavailableEvent.NAME}' started")

    threading.Thread(
        target=consume,
        args=(
            PaymentFailedEvent.NAME,
            lambda body: handle_event(body, "SYSTEM", "PENDING", PaymentFailedEvent.NAME)
        ),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{PaymentFailedEvent.NAME}' started")

    threading.Thread(
        target=consume,
        args=(
            TicketIssuedEvent.NAME,
            lambda body: handle_event(body, "EMAIL", "SENT", TicketIssuedEvent.NAME)
        ),
        daemon=True
    ).start()
    logger.info(f"[Notification] Consumer for '{TicketIssuedEvent.NAME}' started")

def handle_event(body: dict, channel: str, status: str, event_name: str):
    logger.info(f"[Notification][{event_name}] Received '{event_name}': {body}")
    cmd = SendNotificationCommand(
        ticket_id=body.get("ticketId", body.get("bookingId", "")),
        user_id=body.get("userId", ""),
        channel=channel,
        status=status,
        payload=body.get("payload", {})
    )
    notification = handle_send_notification(cmd)
    logger.info(f"[Notification][{event_name}] Saved notification: {notification}")
