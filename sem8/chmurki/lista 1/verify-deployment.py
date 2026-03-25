#!/usr/bin/env python3
import boto3

eb_client = boto3.client('elasticbeanstalk', region_name='us-east-1')


def check_deployment():
    """Check deployment status and endpoints"""
    print("\n" + "="*70)
    print("DEPLOYMENT VERIFICATION")
    print("="*70)
    
    try:
        print("\n[BACKEND]")
        response = eb_client.describe_environments(
            EnvironmentNames=['simple-chat-backend-env']
        )
        if response['Environments']:
            env = response['Environments'][0]
            print(f"  Name: {env['EnvironmentName']}")
            print(f"  Status: {env['Status']}")
            print(f"  Health: {env.get('Health', 'N/A')}")
            print(f"  Created: {env['DateCreated']}")
            if 'CNAME' in env:
                backend_url = f"http://{env['CNAME']}"
                print(f"  URL: {backend_url}")
                print(f"  Health Check: {backend_url}/api/health")
        
        print("\n[FRONTEND]")
        response = eb_client.describe_environments(
            EnvironmentNames=['simple-chat-frontend-env']
        )
        if response['Environments']:
            env = response['Environments'][0]
            print(f"  Name: {env['EnvironmentName']}")
            print(f"  Status: {env['Status']}")
            print(f"  Health: {env.get('Health', 'N/A')}")
            print(f"  Created: {env['DateCreated']}")
            if 'CNAME' in env:
                frontend_url = f"http://{env['CNAME']}"
                print(f"  URL: {frontend_url}")
        
        print("\n[EVENTS - Backend]")
        events = eb_client.describe_events(
            ApplicationName='simple-chat-backend',
            EnvironmentName='simple-chat-backend-env',
            MaxRecords=10
        )
        for event in events.get('Events', [])[:5]:
            timestamp = event['EventDate'].strftime('%H:%M:%S')
            message = event.get('Message', 'N/A')[:60]
            print(f"  {timestamp} - {message}")
        
        print("\n[EVENTS - Frontend]")
        events = eb_client.describe_events(
            ApplicationName='simple-chat-frontend',
            EnvironmentName='simple-chat-frontend-env',
            MaxRecords=10
        )
        for event in events.get('Events', [])[:5]:
            timestamp = event['EventDate'].strftime('%H:%M:%S')
            message = event.get('Message', 'N/A')[:60]
            print(f"  {timestamp} - {message}")
        
        print("\n" + "="*70)
        
    except Exception as e:
        print(f"Error checking deployment: {e}")


if __name__ == "__main__":
    check_deployment()
