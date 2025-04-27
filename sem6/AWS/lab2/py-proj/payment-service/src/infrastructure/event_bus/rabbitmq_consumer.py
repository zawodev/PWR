# src/infrastructure/event_bus/rabbitmq_consumer.py

import pika
import json
from ...infrastructure.config import settings

def consume(routing_key: str, callback):
    """
    1) Subskrybuje jeden routing_key.
    2) Wiąże exchange -> tymczasową kolejkę.
    3) Na odebranie wiadomości wywołuje callback(body_dict).
    """
    params = pika.URLParameters(settings.RABBITMQ_URL)
    connection = pika.BlockingConnection(params)
    channel = connection.channel()

    # Exchange typu topic
    channel.exchange_declare(
        exchange=settings.RABBITMQ_EXCHANGE,
        exchange_type='topic',
        durable=True
    )  # :contentReference[oaicite:0]{index=0}

    # Tymczasowa, unikatowa kolejka
    result = channel.queue_declare('', exclusive=True)
    queue_name = result.method.queue

    # Wiązanie routing key
    channel.queue_bind(
        exchange=settings.RABBITMQ_EXCHANGE,
        queue=queue_name,
        routing_key=routing_key
    )

    # Konsumpcja
    channel.basic_consume(
        queue=queue_name,
        on_message_callback=lambda ch, method, props, body: callback(json.loads(body)),
        auto_ack=True
    )  # :contentReference[oaicite:1]{index=1}

    print(f"[*] Consuming {routing_key}")
    channel.start_consuming()
