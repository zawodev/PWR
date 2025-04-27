# src/infrastructure/event_bus/rabbitmq_consumer.py
import pika, json, logging
from ...infrastructure.config import settings

logger = logging.getLogger(__name__)

def consume(routing_key: str, callback):
    params = pika.URLParameters(settings.RABBITMQ_URL)
    conn = pika.BlockingConnection(params)            # :contentReference[oaicite:7]{index=7}
    ch = conn.channel()
    ch.exchange_declare(exchange=settings.RABBITMQ_EXCHANGE, exchange_type='topic', durable=True)

    q = ch.queue_declare('', exclusive=True).method.queue
    ch.queue_bind(exchange=settings.RABBITMQ_EXCHANGE, queue=q, routing_key=routing_key)
    logger.info(f"[Consumer] Bound to '{routing_key}', waiting for messages...")

    def on_message(ch, method, props, body):
        data = json.loads(body)
        logger.info(f"[Consumer] Received '{method.routing_key}': {data}")
        callback(data)

    ch.basic_consume(queue=q, on_message_callback=on_message, auto_ack=True)
    ch.start_consuming()
