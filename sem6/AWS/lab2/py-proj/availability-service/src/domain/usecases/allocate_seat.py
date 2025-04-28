# availability-service/src/domain/usecases/allocate_seat.py

import random
from ...domain.entities.seat_reservation import SeatReservation
from ...infrastructure.database.seat_repository import SeatRepository

class AllocateSeatUseCase:
    def __init__(self):
        self.repo = SeatRepository()

    def execute(self, data: dict) -> SeatReservation:
        allocated = random.choice([True, True, True, False])
        status = "RESERVED" if allocated else "RELEASED"

        domain = SeatReservation.create(
            booking_id=data["bookingId"],
            match_id=data["matchId"],
            seats=data["seats"],
            status=status
        )
        # zapis domeny do DB
        self.repo.add(domain)
        return domain
