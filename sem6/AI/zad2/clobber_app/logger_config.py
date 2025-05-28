import logging
from colorama import Fore, Style

class ColorFormatter(logging.Formatter):
    def format(self, record):
        msg = super().format(record)
        return Fore.LIGHTYELLOW_EX + msg + Style.RESET_ALL

def setup_logger(verbose: bool = False):
    level = logging.DEBUG if verbose else logging.INFO
    handler = logging.StreamHandler()
    handler.setFormatter(ColorFormatter("%(asctime)s [%(levelname)s] %(message)s"))
    logger = logging.getLogger('clobber')
    logger.setLevel(level)
    logger.handlers = [handler]
    return logger
