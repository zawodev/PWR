import logging
from fastapi import APIRouter, HTTPException
from ...domain.usecases.create_reservation import CreateReservationUseCase
from ...infrastructure.database.reservation_repository import ReservationRepository
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.reservation_created_event import ReservationCreatedEvent

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/")
def create_reservation(request: dict):
    logger.info(f"[Booking][API] Received POST /reservations payload: {request}")
    try:
        # 1. Use case + zapis do DB
        use_case = CreateReservationUseCase()
        reservation = use_case.execute(request)
        # 2. Publikacja eventu
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

@router.get("/")
def list_reservations():
    logger.info("[Booking][API] Received GET /reservations")
    try:
        repo = ReservationRepository()
        all_res = repo.list_all()
        return {"reservations": all_res}
    except Exception as e:
        logger.error(f"[Booking][API] Error in list_reservations: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
