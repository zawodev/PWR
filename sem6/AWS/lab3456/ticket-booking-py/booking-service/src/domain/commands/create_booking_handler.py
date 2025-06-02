import logging
from ...domain.entities.reservation import Reservation
from ...infrastructure.database.booking_repository import BookingRepository
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.reservation_created_event import ReservationCreatedEvent

logger = logging.getLogger(__name__)

class CreateBookingCommand:
    def __init__(self, user_id, match_id, seats, metadata):
        self.user_id = user_id
        self.match_id = match_id
        self.seats = seats
        self.metadata = metadata

def handle_create_booking(cmd: CreateBookingCommand):
    logger.info(f"[Booking][CMD] Handling CreateBooking: {cmd.__dict__}")

    reservation = Reservation.create(
        user_id=cmd.user_id,
        match_id=cmd.match_id,
        seats=cmd.seats,
        metadata=cmd.metadata
    )

    BookingRepository().add(reservation)

    producer.publish(
        routing_key=ReservationCreatedEvent.NAME,
        message=reservation.to_dict()
    )
    return reservation.to_dict()
