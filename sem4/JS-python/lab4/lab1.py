import os
import sys


def env_vars_filter(parameters):
    env_vars = os.environ
    filtered_env_vars = {}

    # jeżeli parametry istnieją, to przefiltruj zmienne środowiskowe
    if parameters:
        for var, val in env_vars.items():
            if any(parameter.lower() in var.lower() for parameter in parameters):
                filtered_env_vars[var] = val
    else:
        filtered_env_vars = env_vars

    # sortuj przefiltrowane i wyświetl
    for var in sorted(filtered_env_vars):
        print(f"{var}={filtered_env_vars[var]}")


if __name__ == "__main__":
    # pomijam pierwszy argument, bo jest nazwą skryptu [1:]
    env_vars_filter(sys.argv[1:])
