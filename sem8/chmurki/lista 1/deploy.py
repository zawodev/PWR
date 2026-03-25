#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path
from datetime import datetime
import boto3
import time

base_dir = Path(__file__).parent.resolve()

required_dirs = ["backend", "frontend"]
for dir_name in required_dirs:
    if not (base_dir / dir_name).is_dir():
        print(f"Error: Cannot find '{dir_name}' directory in {base_dir}")
        sys.exit(1)

eb_client = boto3.client('elasticbeanstalk', region_name='us-east-1')
s3_client = boto3.client('s3', region_name='us-east-1')


def get_aws_account_id():
    """Get AWS account ID"""
    sts = boto3.client('sts', region_name='us-east-1')
    return sts.get_caller_identity()['Account']


def upload_to_s3(file_path, bucket_name, object_key):
    """Upload file to S3"""
    print(f"  Uploading {file_path.name}...")
    try:
        s3_client.upload_file(str(file_path), bucket_name, object_key)
        print(f"  Uploaded to s3://{bucket_name}/{object_key}")
        return True
    except Exception as e:
        print(f"  Upload failed: {e}")
        return False


def create_app_version(app_name, version_label, s3_bucket, s3_key):
    """Create application version in EB"""
    print(f"  Creating app version: {version_label}")
    try:
        response = eb_client.create_application_version(
            ApplicationName=app_name,
            VersionLabel=version_label,
            SourceBundle={
                'S3Bucket': s3_bucket,
                'S3Key': s3_key
            },
            Description=f'Deployment at {datetime.now().isoformat()}'
        )
        print(f"  Created version: {response['ApplicationVersion']['VersionLabel']}")
        return version_label
    except Exception as e:
        print(f"  Failed to create version: {e}")
        return None


def deploy_version(app_name, env_name, version_label):
    """Update environment with new application version"""
    print(f"  Deploying {version_label} to {env_name}...")
    try:
        response = eb_client.update_environment(
            ApplicationName=app_name,
            EnvironmentName=env_name,
            VersionLabel=version_label
        )
        print(f"  Environment update initiated: {response['EnvironmentName']}")
        return True
    except Exception as e:
        print(f"  Deployment failed: {e}")
        return False


def wait_for_deployment(app_name, env_name, max_attempts=60):
    """Wait for environment to reach ready status"""
    print(f"  Waiting for {env_name} to reach Ready status...")
    for attempt in range(max_attempts):
        try:
            response = eb_client.describe_environments(
                ApplicationName=app_name,
                EnvironmentNames=[env_name]
            )
            if response['Environments']:
                env = response['Environments'][0]
                status = env['Status']
                if status == 'Ready':
                    print(f"  Environment is Ready!")
                    return True
                elif status == 'Terminated':
                    print(f"  Environment terminated!")
                    return False
                else:
                    print(f"    Current status: {status}")
        except Exception as e:
            print(f"    Status check error: {e}")
        
        time.sleep(10)
    
    print(f"  Timeout waiting for deployment")
    return False


def package_apps():
    package_script = base_dir / "apps-pack.py"
    if not package_script.exists():
        raise FileNotFoundError(f"Packaging script not found: {package_script}")

    print("Packaging backend and frontend artifacts...")
    subprocess.run(
        [
            sys.executable,
            str(package_script),
            "--region",
            "us-east-1",
            "--backend-env-name",
            "simple-chat-backend-env",
        ],
        cwd=str(base_dir),
        check=True,
    )


def main():
    package_apps()

    account_id = get_aws_account_id()
    print(f"AWS Account ID: {account_id}\n")
    
    eb_deployment_bucket = f"eb-deployments-{account_id}-us-east-1"
    
    print(f"Ensuring S3 bucket exists: {eb_deployment_bucket}")
    try:
        s3_client.head_bucket(Bucket=eb_deployment_bucket)
        print(f"Bucket exists: {eb_deployment_bucket}")
    except Exception:
        print(f"Creating bucket: {eb_deployment_bucket}")
        try:
            s3_client.create_bucket(Bucket=eb_deployment_bucket)
            print(f"Bucket created: {eb_deployment_bucket}")
        except Exception as e:
            print(f"Failed to create bucket: {e}")
            return
    
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    
    print("\n" + "="*60)
    print("BACKEND DEPLOYMENT")
    print("="*60)
    
    backend_zip = base_dir / "backend-deployment.zip"
    backend_version = f"simple-chat-backend-{timestamp}"
    backend_s3_key = f"backend/{timestamp}/backend-deployment.zip"
    
    if backend_zip.exists():
        print(f"Backend package: {backend_zip.name} ({backend_zip.stat().st_size / 1024:.1f} KB)")
        
        if upload_to_s3(backend_zip, eb_deployment_bucket, backend_s3_key):
            if create_app_version("simple-chat-backend", backend_version, eb_deployment_bucket, backend_s3_key):
                if deploy_version("simple-chat-backend", "simple-chat-backend-env", backend_version):
                    wait_for_deployment("simple-chat-backend", "simple-chat-backend-env")
    else:
        print(f"Backend ZIP not found: {backend_zip}")
    
    print("\n" + "="*60)
    print("FRONTEND DEPLOYMENT")
    print("="*60)
    
    frontend_zip = base_dir / "frontend-deployment.zip"
    frontend_version = f"simple-chat-frontend-{timestamp}"
    frontend_s3_key = f"frontend/{timestamp}/frontend-deployment.zip"
    
    if frontend_zip.exists():
        print(f"Frontend package: {frontend_zip.name} ({frontend_zip.stat().st_size / 1024:.1f} KB)")
        
        if upload_to_s3(frontend_zip, eb_deployment_bucket, frontend_s3_key):
            if create_app_version("simple-chat-frontend", frontend_version, eb_deployment_bucket, frontend_s3_key):
                if deploy_version("simple-chat-frontend", "simple-chat-frontend-env", frontend_version):
                    wait_for_deployment("simple-chat-frontend", "simple-chat-frontend-env")
    else:
        print(f"Frontend ZIP not found: {frontend_zip}")
    
    print("\n" + "="*60)
    print("DEPLOYMENT COMPLETE")
    print("="*60)


if __name__ == "__main__":
    main()
