import typer
from typing import Optional
import log_parser_2 as ex2
import logger_3 as ex3
import log_analysis_4 as ex4
import log_bruteforce_6 as ex6

app = typer.Typer()

@app.command()
def handle_logs(log_path: str,
                log_level: str = typer.Option("NONE", help="minimum logging level", case_sensitive=False),
                command: Optional[str] = typer.Argument(None, help="command for 2b, 2c, 2d, 4a etc"),
                interval: Optional[int] = typer.Option(60, help="maximum interval in seconds between failed login attempts"),
                attempts: Optional[int] = typer.Option(5, help="minimum number of failed login attempts to be considered a brute force attack"),
                by_user: Optional[bool] = typer.Option(False, help="detect brute force attempts by user")):
    try:
        with open(log_path, 'r') as file:
            log_file = ex2.parse_log_file(file)

            if log_level != 'NONE':
                ex3.log_the_log_file(log_file, log_level)

            for log_line in log_file:
                if log_line:
                    if command:
                        if command == "2b":
                            ex2.print_ipv4s_from_log(log_line)
                        elif command == "2c":
                            ex2.print_user_from_log(log_line['event'])
                        elif command == "2d":
                            ex2.print_message_type(log_line['event'])

            if command:
                if command == "4a":
                    ex4.print_random_logs_for_user(log_file)
                elif command == "4b":
                    ex4.print_ssh_connection_stats(log_file)
                elif command == "4c":
                    ex4.print_most_and_least_frequent_users(log_file)
                elif command == "4d":
                    ex4.print_log_analysis(log_file)
                elif command == "6a":
                    ex6.print_brute_force_attempts(log_file, interval=interval, attempts=attempts, user_detect=by_user)

    except IOError as e:
        typer.echo(f"Error opening file: {e}")
