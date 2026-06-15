#!/usr/bin/env python3
"""
Deploy script for Projekt 3.

Changes from Projekt 2:
- chat-service no longer deployed as Docker container (replaced by Lambda)
- Lambda deployment: packages handler + deps into a ZIP, uploads to S3,
  then updates the Lambda function code
- notification-service still deployed as ECS Fargate container
"""

import argparse
import json
import os
import subprocess
import sys
import time
import zipfile
from datetime import datetime
from pathlib import Path

try:
    import boto3
except ImportError:
    boto3 = None

BASE_DIR = Path(__file__).parent.resolve()
FRONTEND_DIR = BASE_DIR / "frontend"
SERVICES_DIR = BASE_DIR / "services"
LAMBDAS_DIR = BASE_DIR / "lambdas"


def run(cmd, cwd=None, input_text=None, capture=False):
    result = subprocess.run(
        cmd,
        cwd=cwd,
        input=input_text,
        text=True,
        capture_output=capture,
        check=True,
    )
    return result.stdout if capture else ""


def load_outputs():
    raw = run(["terraform", "output", "-json"], cwd=BASE_DIR, capture=True)
    data = json.loads(raw)
    return {key: value.get("value") for key, value in data.items()}


def require_output(outputs, key):
    value = outputs.get(key)
    if not value:
        raise RuntimeError(f"Missing terraform output: {key}")
    return value


def resolve_region(cli_region):
    if cli_region:
        return cli_region
    return os.getenv("AWS_REGION", "us-east-1")


# ── Docker / ECR ─────────────────────────────────────────────────────────

def docker_login(region, repo_url):
    registry = repo_url.split("/")[0]
    password = run(
        ["aws", "ecr", "get-login-password", "--region", region],
        capture=True,
    ).strip()
    run(
        ["docker", "login", "--username", "AWS", "--password-stdin", registry],
        input_text=password,
    )


def build_and_push_images(outputs, region):
    services = {
        "auth-service": require_output(outputs, "auth_ecr_repo"),
        "media-service": require_output(outputs, "media_ecr_repo"),
        "notification-service": require_output(outputs, "notification_ecr_repo"),
    }

    first_repo = next(iter(services.values()))
    docker_login(region, first_repo)

    for service_name, repo_url in services.items():
        image = f"{repo_url}:latest"
        service_path = SERVICES_DIR / service_name
        if not service_path.is_dir():
            raise FileNotFoundError(f"Missing service directory: {service_path}")

        print(f"Building {service_name} -> {image}")
        run(["docker", "build", "-t", image, str(service_path)])
        print(f"Pushing {image}")
        run(["docker", "push", image])


def force_ecs_deploy(outputs, region):
    if boto3 is None:
        raise RuntimeError("boto3 is required. Install with: pip install boto3")

    ecs = boto3.client("ecs", region_name=region)
    cluster = require_output(outputs, "ecs_cluster_name")

    service_names = [
        require_output(outputs, "ecs_service_auth_name"),
        require_output(outputs, "ecs_service_media_name"),
        require_output(outputs, "ecs_service_notification_name"),
    ]

    for service in service_names:
        print(f"Triggering ECS deployment for {service}")
        ecs.update_service(cluster=cluster, service=service, forceNewDeployment=True)


# ── Lambda ───────────────────────────────────────────────────────────────

def deploy_lambda(outputs, region):
    """Package the chat Lambda handler + deps into a ZIP and update the function."""
    if boto3 is None:
        raise RuntimeError("boto3 is required. Install with: pip install boto3")

    function_name = require_output(outputs, "lambda_chat_function_name")
    s3_bucket = require_output(outputs, "s3_lambda_bucket")
    handler_dir = LAMBDAS_DIR / "chat"

    if not handler_dir.is_dir():
        raise FileNotFoundError(f"Missing lambda directory: {handler_dir}")

    build_dir = BASE_DIR / ".lambda_build"
    build_dir.mkdir(exist_ok=True)

    # Install deps into build dir
    requirements = handler_dir / "requirements.txt"
    if requirements.exists():
        print("Installing Lambda dependencies...")
        run(
            [
                sys.executable, "-m", "pip", "install",
                "-r", str(requirements),
                "-t", str(build_dir),
                "--upgrade",
                "--platform", "manylinux2014_x86_64",
                "--only-binary=:all:",
                "--implementation", "cp",
                "--python-version", "3.12",
            ]
        )

    # Copy handler into build dir
    for py_file in handler_dir.glob("*.py"):
        import shutil
        shutil.copy2(py_file, build_dir / py_file.name)

    # Create ZIP
    zip_path = BASE_DIR / "chat_lambda.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, _dirs, files in os.walk(build_dir):
            for file in files:
                full = Path(root) / file
                arcname = str(full.relative_to(build_dir))
                zf.write(full, arcname)

    print(f"Lambda package: {zip_path} ({zip_path.stat().st_size / 1024:.0f} KB)")

    # Upload to S3
    s3 = boto3.client("s3", region_name=region)
    s3_key = f"lambda/chat/{datetime.now().strftime('%Y%m%d-%H%M%S')}/chat_lambda.zip"
    print(f"Uploading to s3://{s3_bucket}/{s3_key}")
    s3.upload_file(str(zip_path), s3_bucket, s3_key)

    # Update Lambda function code
    lam = boto3.client("lambda", region_name=region)
    print(f"Updating Lambda function: {function_name}")
    lam.update_function_code(
        FunctionName=function_name,
        S3Bucket=s3_bucket,
        S3Key=s3_key,
    )

    print("Lambda deployment complete")


# ── Frontend ─────────────────────────────────────────────────────────────

def create_frontend_zip(api_url, chat_api_url):
    if not FRONTEND_DIR.is_dir():
        raise FileNotFoundError(f"Missing frontend directory: {FRONTEND_DIR}")

    zip_path = BASE_DIR / "frontend-deployment.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.write(FRONTEND_DIR / "Dockerfile", arcname="Dockerfile")
        dockerignore = FRONTEND_DIR / ".dockerignore"
        if dockerignore.exists():
            zf.write(dockerignore, arcname=".dockerignore")
        zf.write(FRONTEND_DIR / "package.json", arcname="package.json")
        package_lock = FRONTEND_DIR / "package-lock.json"
        if package_lock.exists():
            zf.write(package_lock, arcname="package-lock.json")
        zf.write(FRONTEND_DIR / "tsconfig.json", arcname="tsconfig.json")
        zf.write(FRONTEND_DIR / "tsconfig.app.json", arcname="tsconfig.app.json")
        zf.write(FRONTEND_DIR / "index.html", arcname="index.html")
        zf.writestr(
            ".env.production",
            f"VITE_API_URL={api_url}\nVITE_CHAT_API_URL={chat_api_url}\n",
        )

        for root, _, files in os.walk(FRONTEND_DIR / "src"):
            for file in files:
                file_path = Path(root) / file
                arcname = f"src/{file_path.relative_to(FRONTEND_DIR / 'src')}"
                zf.write(file_path, arcname=arcname)

    print(f"Created frontend ZIP: {zip_path}")
    return zip_path


def ensure_eb_bucket(region, s3_client):
    sts = boto3.client("sts", region_name=region)
    account_id = sts.get_caller_identity()["Account"]
    bucket = f"eb-deployments-{account_id}-{region}"
    try:
        s3_client.head_bucket(Bucket=bucket)
    except Exception:
        print(f"Creating EB bucket: {bucket}")
        s3_client.create_bucket(Bucket=bucket)
    return bucket


def wait_for_env(eb_client, app_name, env_name, max_attempts=60):
    for _ in range(max_attempts):
        response = eb_client.describe_environments(
            ApplicationName=app_name,
            EnvironmentNames=[env_name],
        )
        envs = response.get("Environments", [])
        if envs:
            status = envs[0].get("Status")
            if status == "Ready":
                print("Environment is Ready")
                return True
            if status == "Terminated":
                print("Environment terminated")
                return False
            print(f"Waiting for env... status={status}")
        time.sleep(10)
    print("Timeout waiting for environment")
    return False


def deploy_frontend(outputs, region):
    if boto3 is None:
        raise RuntimeError("boto3 is required. Install with: pip install boto3")

    app_name = require_output(outputs, "frontend_app_name")
    env_name = require_output(outputs, "frontend_env_name")
    api_url = require_output(outputs, "alb_url")
    chat_api_url = require_output(outputs, "chat_api_url")

    zip_path = create_frontend_zip(api_url, chat_api_url)

    s3 = boto3.client("s3", region_name=region)
    eb = boto3.client("elasticbeanstalk", region_name=region)

    bucket = ensure_eb_bucket(region, s3)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    s3_key = f"frontend/{timestamp}/frontend-deployment.zip"
    version_label = f"{app_name}-{timestamp}"

    print(f"Uploading frontend bundle to s3://{bucket}/{s3_key}")
    s3.upload_file(str(zip_path), bucket, s3_key)

    print(f"Creating EB app version: {version_label}")
    eb.create_application_version(
        ApplicationName=app_name,
        VersionLabel=version_label,
        SourceBundle={"S3Bucket": bucket, "S3Key": s3_key},
        Description=f"Deployment at {datetime.now().isoformat()}",
    )

    print(f"Updating EB environment: {env_name}")
    eb.update_environment(
        ApplicationName=app_name,
        EnvironmentName=env_name,
        VersionLabel=version_label,
    )

    wait_for_env(eb, app_name, env_name)


# ── Main ─────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--region", help="AWS region override")
    parser.add_argument("--skip-frontend", action="store_true")
    parser.add_argument("--skip-services", action="store_true")
    parser.add_argument("--skip-lambda", action="store_true")
    args = parser.parse_args()

    region = resolve_region(args.region)
    outputs = load_outputs()

    if not args.skip_services:
        build_and_push_images(outputs, region)
        force_ecs_deploy(outputs, region)

    if not args.skip_lambda:
        deploy_lambda(outputs, region)

    if not args.skip_frontend:
        deploy_frontend(outputs, region)

    print("Deployment finished")


if __name__ == "__main__":
    main()
