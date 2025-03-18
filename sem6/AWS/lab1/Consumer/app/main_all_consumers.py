import logging
import threading
import time
from type1_consumer import Type1Consumer
from type2_consumer import Type2Consumer
from type3_consumer import Type3Consumer
from type4_consumer import Type4Consumer

def main():
    logging.basicConfig(level=logging.INFO, format='[ALL-CONSUMERS] %(asctime)s %(name)s %(levelname)s: %(message)s')

    c1a = Type1Consumer("Type1ConsumerA")
    c1b = Type1Consumer("Type1ConsumerB")
    c2 = Type2Consumer()
    c3 = Type3Consumer()
    c4 = Type4Consumer()

    t1 = threading.Thread(target=c1a.run, daemon=True)
    t2 = threading.Thread(target=c1b.run, daemon=True)
    t3 = threading.Thread(target=c2.run, daemon=True)
    t4 = threading.Thread(target=c3.run, daemon=True)
    t5 = threading.Thread(target=c4.run, daemon=True)

    t1.start()
    t2.start()
    t3.start()
    t4.start()
    t5.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        c1a.broker.close()
        c1b.broker.close()
        c2.broker.close()
        c3.broker.close()
        c4.broker.close()
        print("stopped all consumers")

if __name__ == "__main__":
    main()
