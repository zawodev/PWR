import logging
from ...infrastructure.database.booking_repository import BookingRepository

logger = logging.getLogger(__name__)

def handle_list_bookings():
    logger.info("[Booking][QUERY] Listing all bookings")
    bookings = BookingRepository().list_all()
    return [b.__dict__ for b in bookings]
