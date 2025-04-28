# ticketing-service/src/domain/usecases/issue_ticket.py

from ...domain.entities.ticket import Ticket
from ...infrastructure.database.ticket_repository import TicketRepository

class IssueTicketUseCase:
    def __init__(self):
        self.repo = TicketRepository()

    def execute(self, data: dict) -> Ticket:
        qr_code = f"QR{data['bookingId'][:8]}{data['bookingId'][-8:]}"
        ticket = Ticket.create(booking_id=data["bookingId"], qr_code=qr_code)
        self.repo.add(ticket)
        return ticket
