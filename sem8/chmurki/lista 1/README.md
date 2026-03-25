# Simple Group Chat (FastAPI + React)

Global group chat application with media uploads.

- **Backend:** FastAPI + PostgreSQL + S3
- **Frontend:** React 18 + TypeScript + Vite
- **Infrastructure:** AWS Elastic Beanstalk + RDS + S3

## Quick Start

### Deploy to AWS

```bash
terraform init
terraform apply

python package.py
python deploy.py

python verify-deployment.py
```

### Local Development

```bash
docker-compose up
```

Or:
```bash
cd backend && uvicorn app.main:app --reload &
cd frontend && npm run dev
```

---

## Architecture

```
.
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── db.py
│   │   └── routers/
│   │       ├── messages.py
│   │       └── media.py
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── main.tf
├── package.py
├── deploy.py
├── start-infrastructure.py
└── stop-infrastructure.py
```

---

## API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health` | Health check |
| GET | `/api/messages` | List messages |
| POST | `/api/messages` | Create message |
| POST | `/api/media` | Upload file |
| GET | `/api/media/{id}/content` | Download file |

---

## Technology Stack

Backend: FastAPI, PostgreSQL, SQLAlchemy, S3
Frontend: React 18, TypeScript, Vite
Infrastructure: AWS EB, RDS, S3, CloudWatch

---

## Cost Estimation

| Resource | Monthly |
|----------|---------|
| RDS | ~$15 |
| EB Backend | ~$5 |
| EB Frontend | ~$5 |
| S3 | ~$1 |
| **Total** | ~$26 |

Use `stop-infrastructure.py` to reduce costs to ~$1-2/month

---

## Common Tasks

### Deploy Code Changes
```bash
python package.py
python deploy.py
python verify-deployment.py
```

### Save Costs (Stop Infrastructure)
```bash
python stop-infrastructure.py
```

### Resume Infrastructure
```bash
python start-infrastructure.py
```

### Check Status
```bash
python verify-deployment.py
```

---

## Troubleshooting

**Backend shows "Health: Unknown"?**
Check EB logs in AWS Console or run: `aws elasticbeanstalk describe-events --environment-name simple-chat-backend-env`

**Deploy hangs?**
Usually takes 10-20 minutes. Check AWS EB Console for status.

**S3 uploads fail?**
Verify bucket exists and backend has IAM permissions.
