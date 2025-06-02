import logging
from ...domain.entities.ticket import Ticket
from ...infrastructure.database.ticket_repository import TicketRepository
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.ticket_issued_event import TicketIssuedEvent

logger = logging.getLogger(__name__)

class IssueTicketCommand:
    def __init__(self, booking_id: str, qr_code: str, valid_minutes: int):
        self.booking_id = booking_id
        self.qr_code = qr_code
        self.valid_minutes = valid_minutes

def handle_issue_ticket(cmd: IssueTicketCommand):
    logger.info(f"[Ticketing][CMD] Handling IssueTicket: {cmd.__dict__}")

    ticket = Ticket.create(
        booking_id=cmd.booking_id,
        qr_code=cmd.qr_code,
        valid_minutes=cmd.valid_minutes
    )

    TicketRepository().add(ticket)

    producer.publish(
        routing_key=TicketIssuedEvent.NAME,
        message=ticket.to_dict()
    )
    return ticket.to_dict()
