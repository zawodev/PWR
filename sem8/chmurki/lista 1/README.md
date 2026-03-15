# Simple Group Chat (FastAPI + React)

Minimalna aplikacja webowa z jednym globalnym chatem:
- backend: FastAPI (GET/POST)
- frontend: React + TypeScript
- upload i odbieranie plikow multimedialnych (image/audio/video)

## Struktura

- backend
- frontend

Kazdy modul ma osobny Dockerfile i moze byc hostowany niezaleznie.

## Backend - endpointy

- GET /api/health
- GET /api/messages?after_id=123
- POST /api/messages
- POST /api/media
- GET /api/media/{media_id}
- GET /api/media/{media_id}/content

## Uruchomienie backend

1. Przejdz do folderu backend.
2. Zbuduj obraz:
   docker build -t simple-chat-backend .
3. Uruchom kontener:
   docker run --rm -p 8000:8000 -e FRONTEND_ORIGIN=http://localhost:3000 -v chat_uploads:/app/uploads simple-chat-backend

## Uruchomienie frontend

1. Przejdz do folderu frontend.
2. Zbuduj obraz:
   docker build --build-arg VITE_API_URL=http://localhost:8000 -t simple-chat-frontend .
3. Uruchom kontener:
   docker run --rm -p 3000:80 simple-chat-frontend

Uwaga: w produkcji frontend powinien wskazywac poprawny adres backendu przez VITE_API_URL na etapie buildu.

## Lokalny dev bez dockera

Backend:
- pip install -r requirements.txt
- uvicorn app.main:app --reload --port 8000

Frontend:
- npm install
- npm run dev

## Opcjonalnie: start obu uslug razem

- docker compose up --build

## Minimalne kontrakty

POST /api/messages body:
{
  "nickname": "Ala",
  "text": "Czesc",
  "media_id": 1
}

POST /api/media:
- multipart/form-data
- pole: file
