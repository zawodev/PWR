import logging
from consumer_base import ConsumerBase
from Consumer.domain.events.type3_event import Type3Event
from Consumer.domain.events.type4_event import Type4Event

logger = logging.getLogger(__name__)

class Type3Consumer(ConsumerBase):
    def __init__(self):
        super().__init__(Type3Event)

    def process(self, event):
        logger.info("[Type3Consumer] Przetwarzam event: %s", event.data)
        new_event = Type4Event(data=f"Generowane na bazie: {event.data}")
        routing_key = "type4"
        self.broker.publish(routing_key, new_event)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type3Consumer] %(asctime)s %(name)s %(levelname)s: %(message)s')
    consumer = Type3Consumer()
    try:
        consumer.run()
    except KeyboardInterrupt:
        consumer.broker.close()

if __name__ == "__main__":
    main()
