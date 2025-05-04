import logging
from fastapi import APIRouter, HTTPException, status
from ...domain.commands.allocate_seat_handler import AllocateSeatCommand, handle_allocate_seat
from ...domain.queries.list_seat_reservations_handler import handle_list_seats

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post(
    path="/",
    status_code=status.HTTP_201_CREATED,
    summary="Attempt to reserve seats for a booking"
)
def allocate_seat(request: dict):
    logger.info(f"[Availability][API] POST /seats/allocate payload: {request}")
    try:
        cmd = AllocateSeatCommand(
            booking_id=request["bookingId"],
            match_id=request["matchId"],
            seats=request["seats"]
        )
        return handle_allocate_seat(cmd)
    except Exception as e:
        logger.error(f"[Availability][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get(
    path="/",
    status_code=status.HTTP_200_OK,
    summary="List all seat reservations"
)
def list_reservations():
    logger.info("[Availability][API] GET /seats/reservations")
    try:
        return {"seat_reservations": handle_list_seats()}
    except Exception as e:
        logger.error(f"[Availability][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
