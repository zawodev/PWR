import threading
import json
from fastapi import FastAPI
from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..domain.events.seat_allocated_event import SeatAllocatedEvent
from ..domain.events.payment_failed_event import PaymentFailedEvent
from ..domain.events.ticked_issued_event import TicketIssuedEvent

setup_logging()
app = FastAPI()
notifications = []

def handle_notification(event_name, body):
    notifications.append({
        "event": event_name,
        "data": body
    })

@app.on_event("startup")
def startup():
    # subskrybuj kilka routing key
    threading.Thread(target=consume, args=(SeatAllocatedEvent.UNAVAILABLE, lambda b: handle_notification("seat_unavailable", b)), daemon=True).start()
    threading.Thread(target=consume, args=(PaymentFailedEvent.NAME, lambda b: handle_notification("payment_failed", b)), daemon=True).start()
    threading.Thread(target=consume, args=(TicketIssuedEvent.NAME, lambda b: handle_notification("ticket_issued", b)), daemon=True).start()

@app.get("/status")
def status():
    # zwróć ostatnie powiadomienia
    return notifications[-5:]
