# availability-service/src/domain/usecases/allocate_seat.py

import random
from ...domain.entities.seat_reservation import SeatReservation
from ...infrastructure.database.seat_repository import SeatRepository

class AllocateSeatUseCase:
    def __init__(self):
        self.repo = SeatRepository()

    def execute(self, data: dict) -> SeatReservation:
        booking_id = data["bookingId"]
        match_id   = data["matchId"]
        seats_req  = data["seats"]

        reserved = self.repo.list_reserved_seats(match_id)
        conflict = any(s in reserved for s in seats_req)
        status = "RESERVED" if not conflict else "RELEASED"

        domain = SeatReservation.create(
            booking_id=booking_id,
            match_id=match_id,
            seats=seats_req,
            status=status
        )

        self.repo.add(domain)
        return domain
