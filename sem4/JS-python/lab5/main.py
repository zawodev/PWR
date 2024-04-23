import sys

import log_parser_2 as ex2
import logger_3 as ex3
import log_analysis_4 as ex4

# DEFINITIONS:
# file - list of lines
# line - raw line of text from file
# log - parsed line of data in form of a dict

# in some sense this is the file 'ex1'

if __name__ == '__main__':
    log_file = ex2.parse_log_file(sys.stdin)

    ex3.log_the_log_file(log_file)
    ex4.print_log_analysis(log_file)

