import time
import random
import logging
from publisher_base import PublisherBase
from Publisher.domain.events.type2_event import Type2Event

logger = logging.getLogger(__name__)

class Type2Publisher(PublisherBase):
    def __init__(self):
        super().__init__(Type2Event)

    def run(self):
        while True:
            data = "Type2 random data"
            self.publish(data)
            sleep_time = random.randint(1, 5)
            time.sleep(sleep_time)

def main():
    logging.basicConfig(level=logging.INFO, format='[Type2Publisher] %(asctime)s %(name)s %(levelname)s: %(message)s')
    pub = Type2Publisher()
    try:
        pub.run()
    except KeyboardInterrupt:
        pub.broker.close()
        print("stopped type2 publisher")

if __name__ == "__main__":
    main()
