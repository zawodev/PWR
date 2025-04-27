from uuid import uuid4

class IssueTicketUseCase:
    def execute(self, data: dict):
        # generowanie prostego biletu
        ticket_id = str(uuid4())
        return {
            "reservation_id": data["reservation_id"],
            "ticket_id": ticket_id,
            "issued_at": uuid4().hex  # np. timestamp lub inny identyfikator
        }
