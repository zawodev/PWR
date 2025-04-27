from fastapi import APIRouter, HTTPException
from ...domain.usecases.create_reservation import CreateReservationUseCase
from ...infrastructure.event_bus.rabbitmq_producer import producer
from ...domain.events.reservation_created_event import ReservationCreatedEvent

router = APIRouter()

@router.post("/")
def create_reservation(request: dict):
    try:
        # Logika domenowa (Command)
        use_case = CreateReservationUseCase()
        reservation = use_case.execute(request)
        # Publikacja zdarzenia
        producer.publish(
            routing_key=ReservationCreatedEvent.NAME,
            message=reservation.to_dict()
        )
        return reservation.to_dict()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
