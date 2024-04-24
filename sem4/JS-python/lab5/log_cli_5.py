import argparse
import log_parser_2 as ex2
import logger_3 as ex3
import log_analysis_4 as ex4


def init():
    parser = argparse.ArgumentParser(description='CLI tool for handling log files and running module functions.')

    parser.add_argument('log_path', type=str, help='Path to the log file')
    parser.add_argument('--log_level', type=str, choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL', 'NONE'], default='NONE', help='Minimum log level')

    subparsers = parser.add_subparsers(help='Commands for running specific module functions')


    # -------------- EX2 --------------
    # a) print_ipv4s_from_log
    f1 = subparsers.add_parser('2b', help='print_ipv4s_from_log')
    f1.set_defaults(log_line=ex2.print_ipv4s_from_log)
    # b) print_user_from_log
    f2 = subparsers.add_parser('2c', help='print_user_from_log')
    f2.set_defaults(log_event=ex2.print_user_from_log)
    # c) print_message_type
    f3 = subparsers.add_parser('2d', help='print_message_type')
    f3.set_defaults(log_event=ex2.print_message_type)


    # -------------- EX4 --------------
    # a) print_random_logs_for_user
    f4 = subparsers.add_parser('4a', help='print_random_logs_for_user')
    f4.set_defaults(log_file=ex4.print_random_logs_for_user)
    # b) print_ssh_connection_stats
    f5 = subparsers.add_parser('4b', help='print_ssh_connection_stats')
    f5.set_defaults(log_file=ex4.print_ssh_connection_stats)
    # c) print_most_and_least_frequent_users
    f6 = subparsers.add_parser('4c', help='print_most_and_least_frequent_users')
    f6.set_defaults(log_file=ex4.print_most_and_least_frequent_users)
    # c) print_log_analysis
    f7 = subparsers.add_parser('4d', help='print_log_analysis')
    f7.set_defaults(log_file=ex4.print_log_analysis)

    args = parser.parse_args()
    try:
        with open(args.log_path, 'r') as file:
            log_file = ex2.parse_log_file(file)

            if args.log_level != 'NONE':
                ex3.log_the_log_file(log_file, args.log_level)

            if hasattr(args, 'log_file'):
                args.log_file(log_file)

            for log_line in log_file:
                if log_line:
                    if hasattr(args, 'log_line'):
                        args.log_line(log_line)
                    elif hasattr(args, 'log_event'):
                        args.log_event(log_line['event'])
    except IOError as e:
        print(f"Error opening file: {e}")
