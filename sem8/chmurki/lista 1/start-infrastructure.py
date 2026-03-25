#!/usr/bin/env python3
import sys
import boto3
from datetime import datetime

rds_client = boto3.client('rds', region_name='us-east-1')
eb_client = boto3.client('elasticbeanstalk', region_name='us-east-1')

RDS_INSTANCE_ID = "simple-chat-db"
EB_ENVIRONMENTS = {
    "simple-chat-backend": "simple-chat-backend-env",
    "simple-chat-frontend": "simple-chat-frontend-env"
}


def start_rds():
    """Start RDS instance if stopped"""
    print("\nStarting RDS instance...")
    try:
        response = rds_client.describe_db_instances(DBInstanceIdentifier=RDS_INSTANCE_ID)
        instance = response['DBInstances'][0]
        status = instance['DBInstanceStatus']

        if status == 'available':
            print(f"RDS instance is already available")
            return True
        elif status == 'stopped':
            print(f"Starting RDS instance...")
            rds_client.start_db_instance(DBInstanceIdentifier=RDS_INSTANCE_ID)
            print(f"RDS instance is starting (5-10 minutes)")
            return True
        else:
            print(f"RDS instance status: {status}")
            return True

    except rds_client.exceptions.DBInstanceNotFoundFault:
        print(f"RDS instance not found!")
        return False
    except Exception as e:
        print(f"Error starting RDS: {e}")
        return False


def start_eb_environments():
    """Check EB environments status"""
    print("\nChecking EB environments...")
    
    for app_name, env_name in EB_ENVIRONMENTS.items():
        print(f"\nChecking {app_name}...")
        try:
            response = eb_client.describe_environments(
                ApplicationName=app_name,
                EnvironmentNames=[env_name]
            )

            if not response['Environments']:
                print(f"Environment not found")
                continue

            env = response['Environments'][0]
            status = env['Status']
            health = env.get('Health', 'Unknown')

            if status == 'Ready':
                print(f"Environment is Ready (Health: {health})")
            elif status == 'Terminated':
                print(f"Environment is Terminated")
                print(f"Use Terraform to recreate: terraform apply")
            else:
                print(f"Environment status: {status}")

        except Exception as e:
            print(f"Error checking environment: {e}")


def main():
    print("="*60)
    print("START AWS INFRASTRUCTURE")
    print("="*60)
    print(f"Timestamp: {datetime.now().isoformat()}")

    rds_ok = start_rds()
    start_eb_environments()

    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    if rds_ok:
        print("RDS start initiated")
    print("EB environment status checked")
    print("\nCheck AWS Console for completion status")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nOperation cancelled")
        sys.exit(1)
    except Exception as e:
        print(f"\nError: {e}")
        sys.exit(1)
