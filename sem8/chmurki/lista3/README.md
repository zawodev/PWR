# Lista 3 - Serverless Chat (Lambda + SQS + CloudWatch)

Evolved from Lista 2: the chat microservice is replaced by AWS Lambda functions,
notifications use an event-driven SQS pipeline, and comprehensive CloudWatch
monitoring is in place.

## Architecture

- **Frontend**: React + Vite (Elastic Beanstalk)
- **Auth service**: FastAPI + Cognito + DynamoDB (Fargate)
- **Chat service**: **AWS Lambda** + API Gateway HTTP API + RDS (PostgreSQL)
- **Media service**: FastAPI + S3 + DynamoDB (Fargate)
- **Notification service**: FastAPI + **SQS worker** + SNS + DynamoDB (Fargate)

### Event-driven notification flow

```
Lambda (chat) ──▶ SQS Queue ──▶ Notification Service (Fargate worker)
                                      │
                                      ├─▶ DynamoDB (idempotent write)
                                      └─▶ SNS (email notification)
                     │
              (after 3 failures)
                     │
                     ▼
              SQS Dead Letter Queue
```

### Multi-chat features

Users can create, join, and leave chats. System messages are generated for
join/leave events. The chat sidebar shows "my chats" and browsable chats.

## Changes from Lista 2

| Component | Lista 2 | Lista 3 |
|---|---|---|
| Chat logic | Fargate (FastAPI) | **Lambda** (Python handler) |
| Chat routing | ALB path-based | **API Gateway HTTP API** |
| Notifications trigger | HTTP POST | **SQS publish** |
| Notification processing | HTTP endpoint only | **SQS long-polling worker** |
| Dead Letter Queue | none | **SQS DLQ (3 retries)** |
| Idempotency | none | **DynamoDB conditional put** |
| CloudWatch | basic ECS logs | **Log groups + alarms + dashboard** |
| Chat model | single global chat | **Multi-chat (create/join/leave)** |

## Endpoints

### Lambda (API Gateway)
- GET /api/chats – list all chats
- GET /api/chats/my – list chats user has joined
- GET /api/chats/{id} – get single chat
- GET /api/chats/{id}/messages – list messages
- GET /api/chats/{id}/members – list members
- GET /api/messages – default (global) chat messages
- POST /api/chats – create chat
- POST /api/chats/{id}/messages – send message
- POST /api/chats/{id}/join – join chat
- POST /api/chats/{id}/leave – leave chat
- POST /api/messages – send to default chat

### Fargate services (ALB)
- Auth: /api/auth/* (unchanged)
- Media: /api/media/* (unchanged)
- Notifications: /api/notifications/* (unchanged)

## Terraform

The infrastructure is defined in [main.tf](main.tf). New resources include:
- Lambda function + API Gateway HTTP API
- SQS queue + Dead Letter Queue
- CloudWatch log groups, metric alarms, and dashboard
- Lambda security group (VPC access to RDS)

### Apply

```bash
terraform init
terraform apply
```

### Deploy

```bash
python deploy.py
# Options: --skip-frontend, --skip-services, --skip-lambda
```

## Local development

```bash
# Copy .env.example to .env and fill in AWS credentials
copy .env.example .env

# Start Fargate services locally
docker compose up --build

# Start frontend
cd frontend
npm install
npm run dev
```

Note: Chat Lambda is NOT included in docker-compose. Use the deployed API Gateway
endpoint, or run `handler.py` locally with a PostgreSQL connection.

## CloudWatch

- **Dashboard**: `micro-chat-dashboard` – Lambda invocations, errors, duration;
  SQS queue depth; ECS CPU/memory
- **Alarms**: Lambda errors (>5/5min), Lambda duration (avg >10s),
  SQS backlog (>100 messages), DLQ non-empty
