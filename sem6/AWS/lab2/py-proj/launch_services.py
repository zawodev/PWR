# launch_services.py

import subprocess
import sys
import time
import os
from pathlib import Path

# Ścieżki i porty mikroserwisów
SERVICES = [
    ("booking-service", 8000),
    ("availability-service", 8001),
    ("payment-service", 8002),
    ("ticketing-service", 8003),
    ("notification-service", 8004),
]

# 1) Uruchomienie RabbitMQ w tle
def start_rabbitmq():
    # Sprawdź, czy kontener już istnieje
    existing = subprocess.run(
        ["docker", "ps", "-a", "--filter", "name=rabbitmq-test", "--format", "{{.Names}}"],
        capture_output=True, text=True
    ).stdout.strip()

    if existing != "rabbitmq-test":
        print("🟢 Tworzę i uruchamiam RabbitMQ…")
        subprocess.check_call([
            "docker", "run", "-d",
            "--name", "rabbitmq-test",
            "-p", "5672:5672",
            "-p", "15672:15672",
            "rabbitmq:3-management"
        ])
        # daj czas na start brokera
        time.sleep(5)
    else:
        # jeśli jest, uruchom, jeśli zatrzymany
        status = subprocess.run(
            ["docker", "inspect", "-f", "{{.State.Running}}", "rabbitmq-test"],
            capture_output=True, text=True
        ).stdout.strip()
        if status != "true":
            print("🟡 Uruchamiam istniejący kontener RabbitMQ…")
            subprocess.check_call(["docker", "start", "rabbitmq-test"])
            time.sleep(5)

# 2) Uruchamianie mikroserwisów
def start_services():
    procs = []
    cwd = Path(__file__).parent
    for folder, port in SERVICES:
        service_path = cwd / folder
        env = os.environ.copy()
        # ustaw .env z RabbitMQ lokalnym
        env["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
        # jeśli masz lokalną bazę sqlite do testów, możesz podstawić np.:
        env["DATABASE_URL"] = f"sqlite:///{Path(service_path / 'test.db').as_posix()}"
        cmd = [
            sys.executable, "-m", "uvicorn",
            "src.app.main:app",
            "--reload",
            "--host", "127.0.0.1",
            "--port", str(port)
        ]
        print(f"🟢 Uruchamiam {folder} na porcie {port}…")
        p = subprocess.Popen(cmd, cwd=service_path, env=env)
        procs.append(p)
        # daj chwilę, żeby service się wystartował
        time.sleep(1)
    return procs

if __name__ == "__main__":
    start_rabbitmq()
    """
    print("🟢 RabbitMQ uruchomiony.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("🛑 Zatrzymywanie RabbitMQ…")
        subprocess.run(["docker", "stop", "rabbitmq-test"])
        print("✔️ RabbitMQ zatrzymany.")

    """
    procs = start_services()
    print("✅ Wszystkie usługi wystartowane. Możesz teraz odpalić test_flow.py")
    try:
        # trzymaj skrypt uruchomiony, żeby nie zabijać procesów
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("🛑 Zatrzymywanie usług…")
        for p in procs:
            p.terminate()
        subprocess.run(["docker", "stop", "rabbitmq-test"])
        print("✔️ Wszystko zatrzymane.")
    
