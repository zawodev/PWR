import logging
from fastapi import APIRouter, HTTPException, status
from ...domain.events.reservation_created_event import ReservationCreatedEvent
from ...domain.commands.create_booking_handler import handle_create_booking, CreateBookingCommand
from ...domain.queries.list_bookings_handler import handle_list_bookings

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/", status_code=status.HTTP_201_CREATED)
def create_reservation(request: dict):
    logger.info(f"[Booking][API] Received POST /reservations payload: {request}")
    try:
        logger.info(f"[Booking][Event] Publishing '{ReservationCreatedEvent.NAME}': {request}")
        cmd = CreateBookingCommand(
            user_id=request["userId"],
            match_id=request["matchId"],
            seats=request["seats"],
            metadata=request.get("metadata", {})
        )
        return handle_create_booking(cmd)

    except Exception as e:
        logger.error(f"[Booking][API] Error in create_reservation: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/", status_code=status.HTTP_200_OK)
def list_reservations():
    logger.info("[Booking][API] Received GET /reservations")
    try:
        return {"reservations": handle_list_bookings()}
    except Exception as e:
        logger.error(f"[Booking][API] Error in list_reservations: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
