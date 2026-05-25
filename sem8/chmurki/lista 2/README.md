# Lista 2 - Microservices Group Chat

Microservices chat application built from the Lista 1 codebase and expanded for AWS Fargate.

## Architecture

- Frontend: React + Vite (separate module)
- Auth service: FastAPI + Cognito + DynamoDB
- Chat service: FastAPI + RDS (PostgreSQL)
- Media service: FastAPI + S3 + DynamoDB
- Notification service: FastAPI + SNS + DynamoDB

Each ECS service runs on Fargate with autoscaling (min 2 tasks) and a shared ALB with path-based routing.

## Endpoints (minimum requirements)

Auth service
- GET /api/auth/health
- GET /api/auth/config
- GET /api/auth/me
- GET /api/auth/profile
- POST /api/auth/login
- POST /api/auth/register

Chat service
- GET /api/chats
- GET /api/chats/{chat_id}
- GET /api/chats/{chat_id}/messages
- GET /api/messages
- POST /api/chats
- POST /api/chats/{chat_id}/messages
- POST /api/messages

Media service
- GET /api/media/health
- GET /api/media/{media_id}
- GET /api/media/{media_id}/content
- POST /api/media

Notification service
- GET /api/notifications/health
- GET /api/notifications
- GET /api/notifications/{notification_id}
- POST /api/notifications

## Local docker-compose

This runs the microservices locally with a reverse proxy gateway on port 8000.

1. Copy the example env file and fill AWS values:
   - `copy .env.example .env`
2. Start all services:
   - `docker compose up --build`
3. Start the frontend separately:
   - `cd frontend`
   - `npm install`
   - `npm run dev`
   - open `http://localhost:5173`

Notes:
- Auth login/register requires Cognito to be configured.
- Media uploads require S3 + DynamoDB.
- Notifications require SNS + DynamoDB.
- Frontend is not built inside docker-compose to avoid long npm installs.

## Terraform

The infrastructure is defined in [main.tf](main.tf). Resources include:
- ECS cluster with four Fargate services
- ALB with path-based routing
- Elastic Beanstalk environment for the frontend
- RDS (PostgreSQL) for chat service
- DynamoDB tables for auth, media, and notifications
- S3 bucket for media files
- SNS topic for notifications
- Cognito user pool for authentication

AWS Academy note: IAM role creation is blocked, so ECS task roles must be pre-existing.
Use the provided variables to point to existing roles (defaults assume LabRole).

### Apply

1. Initialize and apply Terraform:
   - `terraform init`
   - `terraform apply`

2. Deploy frontend + microservices using the unified script:
   - `python deploy.py`

The script reads `terraform output -json`, pushes images to ECR, forces ECS deployments,
and packages/deploys the frontend to Elastic Beanstalk.

## Project structure

- [frontend/](frontend/) - React frontend
- [services/auth-service/](services/auth-service/) - Cognito auth service
- [services/chat-service/](services/chat-service/) - Chat logic service (RDS)
- [services/media-service/](services/media-service/) - Media upload service (S3 + DynamoDB)
- [services/notification-service/](services/notification-service/) - SNS notification service
