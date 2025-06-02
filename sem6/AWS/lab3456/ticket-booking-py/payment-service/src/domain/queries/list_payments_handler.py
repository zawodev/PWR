from ...infrastructure.database.payment_repository import PaymentRepository
def handle_list_payments():
    return [p.__dict__ for p in PaymentRepository().list_all()]
