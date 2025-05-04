import logging
from ...infrastructure.database.ticket_repository import TicketRepository

logger = logging.getLogger(__name__)

def handle_list_tickets():
    logger.info("[Ticketing][QUERY] Listing all tickets")
    tickets = TicketRepository().list_all()
    return [t.__dict__ for t in tickets]
