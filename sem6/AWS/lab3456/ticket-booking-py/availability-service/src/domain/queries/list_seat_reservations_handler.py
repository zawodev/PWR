import logging
from ...infrastructure.database.seat_repository import SeatRepository

logger = logging.getLogger(__name__)

def handle_list_seats():
    return [r.__dict__ for r in SeatRepository().list_all()]
