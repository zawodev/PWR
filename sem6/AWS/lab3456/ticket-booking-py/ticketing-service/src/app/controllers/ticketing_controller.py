import logging
import random
from fastapi import APIRouter, HTTPException, status

from ...domain.commands.issue_ticket_handler import IssueTicketCommand, handle_issue_ticket
from ...domain.queries.list_tickets_handler import handle_list_tickets

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post(
    path="/",
    status_code=status.HTTP_201_CREATED,
    summary="Issue a ticket"
)
def issue_ticket(request: dict):
    logger.info(f"[Ticketing][API] POST /tickets payload: {request}")
    try:
        cmd = IssueTicketCommand(
            booking_id=request["bookingId"],
            qr_code=f"QR{request['bookingId'][:8]}{request['bookingId'][-8:]}",
            valid_minutes=random.randint(5, 120)
        )
        return handle_issue_ticket(cmd)
    except Exception as e:
        logger.error(f"[Ticketing][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get(
    path="/",
    status_code=status.HTTP_200_OK,
    summary="List all tickets"
)
def list_tickets():
    logger.info("[Ticketing][API] GET /tickets")
    try:
        return {"tickets": handle_list_tickets()}
    except Exception as e:
        logger.error(f"[Ticketing][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
