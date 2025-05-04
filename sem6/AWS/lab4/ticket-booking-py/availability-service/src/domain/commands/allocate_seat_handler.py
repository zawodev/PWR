import logging
from ...domain.entities.seat_reservation import SeatReservation
from ...infrastructure.database.seat_repository import SeatRepository
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.seat_allocated_event import SeatAllocatedEvent
from ...domain.events.seat_unavailable_event import SeatUnavailableEvent

logger = logging.getLogger(__name__)

class AllocateSeatCommand:
    def __init__(self, booking_id, match_id, seats):
        self.booking_id = booking_id
        self.match_id = match_id
        self.seats = seats

def handle_allocate_seat(cmd: AllocateSeatCommand):
    repo = SeatRepository()
    reserved = repo.list_reserved_seats(cmd.match_id)
    conflict = any(s in reserved for s in cmd.seats)
    status = "RESERVED" if not conflict else "RELEASED"
    domain = SeatReservation.create(
        booking_id=cmd.booking_id,
        match_id=cmd.match_id,
        seats=cmd.seats,
        status=status
    )
    repo.add(domain)
    key = SeatAllocatedEvent.NAME if status == "RESERVED" else SeatUnavailableEvent.NAME
    producer.publish(routing_key=key, message=domain.to_dict())
    return domain.to_dict()
