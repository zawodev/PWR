import logging
from fastapi import APIRouter, HTTPException, status
from ...domain.usecases.create_reservation import CreateReservationUseCase
from ...domain.events.reservation_created_event import ReservationCreatedEvent
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...infrastructure.database.models import BookingORM
from ...infrastructure.database.booking_repository import BookingRepository

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_reservation(request: dict):
    logger.info(f"[Booking][API] Received POST /reservations payload: {request}")
    try:
        reservation = CreateReservationUseCase().execute(request)
        event_body = reservation.to_dict()
        logger.info(f"[Booking][Event] Publishing '{ReservationCreatedEvent.NAME}': {event_body}")
        producer.publish(
            routing_key=ReservationCreatedEvent.NAME,
            message=event_body
        )
        return event_body

    except Exception as e:
        logger.error(f"[Booking][API] Error in create_reservation: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", status_code=status.HTTP_200_OK)
def list_reservations():
    logger.info("[Booking][API] Received GET /reservations")
    try:
        from ...infrastructure.database.booking_repository import BookingRepository
        bookings = BookingRepository().list_all()
        return {"reservations": [b.__dict__ for b in bookings]}
    except Exception as e:
        logger.error(f"[Booking][API] Error in list_reservations: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
