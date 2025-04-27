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

setup_logging()
app = FastAPI()
last_event = {}

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(PaymentSucceededEvent.NAME, handle_payment_succeeded),
        daemon=True
    ).start()

def handle_payment_succeeded(body: dict):
    uc = IssueTicketUseCase()
    ticket = uc.execute(body)
    producer.publish(
        routing_key=TicketIssuedEvent.NAME,
        message=ticket
    )
    last_event.update(ticket)

@app.get("/status")
def status():
    return last_event
