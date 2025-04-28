from ...infrastructure.database.booking_repository import BookingRepository
from ...domain.entities.reservation import Reservation

class CreateReservationUseCase:
    def __init__(self):
        self.repo = BookingRepository()

    def execute(self, data: dict) -> Reservation:
        reservation = Reservation.create(
            user_id=data["userId"],
            match_id=data["matchId"],
            seats=data["seats"],
            metadata=data.get("metadata", {})
        )
        self.repo.add(reservation)
        return reservation
