import threading
import logging

from fastapi import FastAPI

from ..infrastructure.logging_config import setup_logging
from ..infrastructure.config import settings
from ..infrastructure.event_bus.rabbitmq_consumer import consume
from ..infrastructure.event_bus.rabbitmq_producer import producer
from ..domain.events.payment_succeeded_event import PaymentSucceededEvent
from ..domain.events.ticket_issued_event import TicketIssuedEvent
from ..domain.usecases.issue_ticket import IssueTicketUseCase
from ..infrastructure.database.ticket_repository import TicketRepository
from ..infrastructure.database.session import SessionLocal

setup_logging()
logger = logging.getLogger(__name__)
app = FastAPI(title="Ticketing Service")

@app.on_event("startup")
def startup():
    threading.Thread(
        target=consume,
        args=(PaymentSucceededEvent.NAME, handle_payment_succeeded),
        daemon=True
    ).start()
    logger.info(f"[Ticketing] Started consumer for '{PaymentSucceededEvent.NAME}'")

def handle_payment_succeeded(body: dict):
    logger.info(f"[Ticketing] Received '{PaymentSucceededEvent.NAME}': {body}")
    uc = IssueTicketUseCase()
    result = uc.execute(body)

    repo = TicketRepository()
    repo.add(result)

    event_body = result.to_dict()
    logger.info(f"[Ticketing] Publishing '{TicketIssuedEvent.NAME}': {event_body}")
    producer.publish(routing_key=TicketIssuedEvent.NAME, message=event_body)

@app.get("/tickets")
def list_tickets():
    logger.info("[Ticketing][API] GET /tickets")
    items = TicketRepository().list_all()
    return {"tickets": [item.__dict__ for item in items]}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("src.app.main:app", host="127.0.0.1", port=8003, log_level="info")
