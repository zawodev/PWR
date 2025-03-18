import logging
import re
from rabbitmq_broker import RabbitMQBroker

logger = logging.getLogger(__name__)

class ConsumerBase:
    def __init__(self, event_class):
        self.event_class = event_class
        self.channel_name = self._derive_channel_name(event_class)

        # Konsument ma własne połączenie do RabbitMQ
        self.broker = RabbitMQBroker()

    def _derive_channel_name(self, event_class):
        class_name = event_class.__name__
        return re.sub(r'Event$', '', class_name).lower()

    def run(self):
        """
        Subskrybuje się i zaczyna konsumować w pętli.
        """
        logger.info("Consumer %s czeka na zdarzenia typu %s (kanał: %s)",
                    self.__class__.__name__, self.event_class.__name__, self.channel_name)
        self.broker.subscribe_and_consume(self.channel_name, self._on_message)

    def _on_message(self, event_class_name, data):
        """
        Callback wywoływany przy odebraniu wiadomości z RabbitMQ.
        Tutaj decydujemy, czy klasa eventu się zgadza (w prostym przykładzie wystarczy sprawdzić nazwy).
        """
        if event_class_name == self.event_class.__name__:
            # Tworzymy instancję eventu
            event_obj = self.event_class(data)
            logger.info("Consumer %s otrzymał event: %s", self.__class__.__name__, event_class_name)
            self.process(event_obj)
        else:
            logger.warning("Odebrano event innego typu: %s (oczekiwano %s)", event_class_name, self.event_class.__name__)

    def process(self, event):
        """
        Logika przetwarzania eventu – do nadpisania w klasach potomnych.
        """
        raise NotImplementedError
