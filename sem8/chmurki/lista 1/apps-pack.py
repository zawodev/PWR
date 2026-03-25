#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
import zipfile
import json
from pathlib import Path

try:
    import boto3
except ImportError:
    boto3 = None

base_dir = Path(__file__).parent.resolve()

required_dirs = ["backend", "frontend"]
for dir_name in required_dirs:
    if not (base_dir / dir_name).is_dir():
        print(f"Error: Cannot find '{dir_name}' directory in {base_dir}")
        sys.exit(1)


def resolve_backend_api_url(api_url: str | None, region: str, backend_env_name: str) -> str:
    if api_url:
        return api_url.rstrip("/")

    env_api = os.getenv("VITE_API_URL")
    if env_api:
        return env_api.rstrip("/")

    if boto3 is not None:
        eb_client = boto3.client("elasticbeanstalk", region_name=region)
        response = eb_client.describe_environments(EnvironmentNames=[backend_env_name])
    else:
        cli_result = subprocess.run(
            [
                "aws",
                "elasticbeanstalk",
                "describe-environments",
                "--environment-names",
                backend_env_name,
                "--region",
                region,
                "--output",
                "json",
            ],
            capture_output=True,
            text=True,
            check=True,
        )
        response = json.loads(cli_result.stdout)
    environments = [e for e in response.get("Environments", []) if e.get("Status") != "Terminated"]
    if not environments:
        raise RuntimeError(
            "Could not resolve backend URL from Elastic Beanstalk. "
            "Provide --api-url explicitly."
        )

    environments.sort(key=lambda e: e.get("DateUpdated") or e.get("DateCreated"), reverse=True)
    cname = environments[0].get("CNAME")
    if not cname:
        raise RuntimeError("Active backend environment has no CNAME.")

    return f"http://{cname}"


def create_backend_zip():
    """Create ZIP file for backend"""
    zip_path = base_dir / "backend-deployment.zip"
    backend_dir = base_dir / "backend"
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.write(backend_dir / "Dockerfile", arcname="Dockerfile")
        zf.write(backend_dir / "requirements.txt", arcname="requirements.txt")
        zf.write(backend_dir / ".dockerignore", arcname=".dockerignore")
        
        for root, dirs, files in os.walk(backend_dir / "app"):
            for file in files:
                file_path = Path(root) / file
                arcname = f"app/{file_path.relative_to(backend_dir / 'app')}"
                zf.write(file_path, arcname=arcname)
        
        procfile = backend_dir / "Procfile"
        if procfile.exists():
            zf.write(procfile, arcname="Procfile")
    
    print(f"Created backend ZIP: {zip_path}")
    return zip_path


def create_frontend_zip(api_url: str):
    """Create ZIP file for frontend"""
    zip_path = base_dir / "frontend-deployment.zip"
    frontend_dir = base_dir / "frontend"
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.write(frontend_dir / "Dockerfile", arcname="Dockerfile")
        zf.write(frontend_dir / ".dockerignore", arcname=".dockerignore")
        zf.write(frontend_dir / "package.json", arcname="package.json")
        zf.write(frontend_dir / "package-lock.json", arcname="package-lock.json")
        zf.write(frontend_dir / "tsconfig.json", arcname="tsconfig.json")
        zf.write(frontend_dir / "tsconfig.app.json", arcname="tsconfig.app.json")
        zf.write(frontend_dir / "index.html", arcname="index.html")
        zf.writestr(".env.production", f"VITE_API_URL={api_url}\n")

        for root, dirs, files in os.walk(frontend_dir / "src"):
            for file in files:
                file_path = Path(root) / file
                arcname = f"src/{file_path.relative_to(frontend_dir / 'src')}"
                zf.write(file_path, arcname=arcname)
    
    print(f"Created frontend ZIP: {zip_path}")
    return zip_path


def main():
    """Package backend and frontend for deployment"""
    parser = argparse.ArgumentParser()
    parser.add_argument("--api-url", help="Backend API URL for frontend build")
    parser.add_argument("--region", default="us-east-1")
    parser.add_argument("--backend-env-name", default="simple-chat-backend-env")
    args = parser.parse_args()

    api_url = resolve_backend_api_url(args.api_url, args.region, args.backend_env_name)
    print(f"Using frontend API URL: {api_url}")

    create_backend_zip()
    create_frontend_zip(api_url)
    print("\nZIP files ready for deployment")


if __name__ == "__main__":
    main()
