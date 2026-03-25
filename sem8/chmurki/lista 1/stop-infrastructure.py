
#!/usr/bin/env python3
import sys
import boto3
import time
from datetime import datetime

rds_client = boto3.client('rds', region_name='us-east-1')
eb_client = boto3.client('elasticbeanstalk', region_name='us-east-1')

RDS_INSTANCE_ID = "simple-chat-db"
EB_ENVIRONMENTS = {
    "simple-chat-backend": "simple-chat-backend-env",
    "simple-chat-frontend": "simple-chat-frontend-env"
}


def stop_rds():
    """Stop RDS instance (data preserved, compute stopped)"""
    print("\nStopping RDS instance...")
    try:
        response = rds_client.describe_db_instances(DBInstanceIdentifier=RDS_INSTANCE_ID)
        instance = response['DBInstances'][0]
        status = instance['DBInstanceStatus']

        if status == 'stopped':
            print(f"RDS instance is already stopped")
            return True
        elif status == 'available':
            print(f"Stopping RDS instance (data preserved)...")
            rds_client.stop_db_instance(DBInstanceIdentifier=RDS_INSTANCE_ID)
            print(f"RDS instance is stopping...")
            return True
        else:
            print(f"RDS instance status: {status}")
            print(f"Cannot stop instance in this state")
            return True

    except rds_client.exceptions.DBInstanceNotFoundFault:
        print(f"RDS instance not found!")
        return False
    except Exception as e:
        print(f"Error stopping RDS: {e}")
        return False


def terminate_eb_environments():
    """Terminate EB environments (saves compute costs)"""
    print("\nTerminating EB environments...")
    
    for app_name, env_name in EB_ENVIRONMENTS.items():
        print(f"\nTerminating {env_name}...")
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

            if status == 'Terminated':
                print(f"Environment already terminated")
            else:
                print(f"Sending termination request...")
                eb_client.terminate_environment(EnvironmentName=env_name)
                print(f"Environment is terminating (5-10 minutes)")

        except Exception as e:
            print(f"Error: {e}")


def confirm_action():
    """Ask for user confirmation"""
    print("\n" + "="*60)
    print("WARNING: Cost Reduction Mode")
    print("="*60)
    print("\nThis will:")
    print("  • STOP RDS instance (data preserved)")
    print("  • TERMINATE EB environments (saves costs)")
    print("\nTo resume: python start-infrastructure.py")
    
    response = input("\nContinue? (type 'yes' to confirm): ").strip().lower()
    return response == 'yes'


def main():
    print("="*60)
    print("STOP AWS INFRASTRUCTURE")
    print("="*60)
    print(f"Timestamp: {datetime.now().isoformat()}")

    if not confirm_action():
        print("\nOperation cancelled")
        sys.exit(0)

    print("\nProceeding with infrastructure shutdown...")
    
    rds_ok = stop_rds()
    terminate_eb_environments()

    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    print("Infrastructure shutdown initiated")
    print(f"RDS Status: {'Stopping...' if rds_ok else 'Error'}")
    print("EB environments: Terminating...")
    print("\nCost Impact:")
    print("  RDS: reduced costs")
    print("  EB: no compute costs")
    print("\nCheck AWS Console for completion")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nOperation cancelled")
        sys.exit(1)
    except Exception as e:
        print(f"\nError: {e}")
        sys.exit(1)
