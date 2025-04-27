import requests
import time

BASE = {
    "booking": "http://localhost:8000",
    "availability": "http://localhost:8001",
    "payment": "http://localhost:8002",
    "ticketing": "http://localhost:8003",
    "notification": "http://localhost:8004"
}

def test_end_to_end():
    # 1. Utwórz rezerwację
    r = requests.post(
        url=f"{BASE['booking']}/reservations/",
        json={"match_id": "m1", "user_id": "u1"}
    )
    assert r.status_code == 200
    res = r.json()
    res_id = res["id"]

    # 2. Poczekaj na alokację miejsc
    s = None
    for _ in range(10):
        s = requests.get(f"{BASE['availability']}/status").json()
        if s.get("reservation_id") == res_id:
            break
        time.sleep(0.5)
    assert "allocated" in s

    # 3. Poczekaj na płatność
    p = None
    for _ in range(10):
        p = requests.get(f"{BASE['payment']}/status").json()
        if p.get("reservation_id") == res_id:
            break
        time.sleep(0.5)
    assert "succeeded" in p or "failed" in p

    # 4. Gdy płatność OK → ticket
    t = None
    if p.get("succeeded"):
        for _ in range(10):
            t = requests.get(f"{BASE['ticketing']}/status").json()
            if t.get("reservation_id") == res_id:
                break
            time.sleep(0.5)
        assert "ticket_id" in t

    # 5. W każdym wypadku mamy powiadomienie
    n = requests.get(f"{BASE['notification']}/status").json()
    assert n is not None

if __name__ == "__main__":
    test_end_to_end()
