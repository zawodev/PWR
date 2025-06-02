import logging
from fastapi import APIRouter, HTTPException, status

from ...domain.commands.process_payment_handler import ProcessPaymentCommand, handle_process_payment
from ...domain.queries.list_payments_handler import handle_list_payments

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post(
    path="/",
    status_code=status.HTTP_201_CREATED,
    summary="Initiate a payment"
)
def create_payment(request: dict):
    logger.info(f"[Payment][API] POST /payments payload: {request}")
    try:
        cmd = ProcessPaymentCommand(
            booking_id=request["bookingId"],
            amount=request["amount"],
            currency=request["currency"]
        )
        return handle_process_payment(cmd)
    except Exception as e:
        logger.error(f"[Payment][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get(
    path="/",
    status_code=status.HTTP_200_OK,
    summary="List all payments"
)
def list_payments():
    logger.info("[Payment][API] GET /payments")
    try:
        return {"payments": handle_list_payments()}
    except Exception as e:
        logger.error(f"[Payment][API] Error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))
