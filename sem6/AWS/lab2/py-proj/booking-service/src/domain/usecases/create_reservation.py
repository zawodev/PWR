from ...infrastructure.database.reservation_repository import ReservationRepository
from ...domain.entities.reservation import Reservation

class CreateReservationUseCase:
    def __init__(self):
        self.repo = ReservationRepository()

    def execute(self, data: dict):
        # 1. Stworzenie encji
        reservation = Reservation.create(
            match_id=data["match_id"], user_id=data["user_id"]
        )
        # 2. Zapis do bazy (Command)
        self.repo.add(reservation)
        return reservation
