import logging
from uuid import UUID
from sqlalchemy.orm import Session
from ...infrastructure.database.models import BookingORM
from ...infrastructure.database.session import SessionLocal
from ...domain.entities.reservation import Reservation

logger = logging.getLogger(__name__)

class BookingRepository:
    def __init__(self):
        self.session: Session = SessionLocal()

    def add(self, reservation: Reservation):
        logger.info(f"[Booking][DB] Mapping Reservation → BookingORM for id={reservation.id}")
        booking = BookingORM(
            booking_id=reservation.id,
            user_id=reservation.user_id,
            match_id=reservation.match_id,
            seats=reservation.seats,
            status=reservation.status,
            extra_metadata=reservation.metadata
        )
        logger.info(f"[Booking][DB] Inserting booking: {booking.__dict__}")
        self.session.merge(booking)
        self.session.commit()

    def list_all(self):
        logger.info("[Booking][DB] Querying all bookings")
        return self.session.query(BookingORM).all()
