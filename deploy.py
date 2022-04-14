import argparse

import boto3
import io


REGION = "ap-northeast-2"
APPLICATION_NAME="ecs-deploy-app"
DEPLOYMNET_GROUP_NAME = "ecs-deploy-group"
BUCKET = "pikurate-bluegreen-bucket"
APPSPEC_NAME = "appspec.yaml"
appspec_tamplate = lambda task_definition, capacity_provider: f"""
version: 1.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "{task_definition}"
        LoadBalancerInfo:
          ContainerName: "web"
          ContainerPort: 80
      CapacityProviderStrategy:
      - CapacityProvider: "{capacity_provider}"
        Base: 0
        Weight: 1
"""

def define_argparser():
    args = argparse.ArgumentParser()
    args.add_argument("--access_key", type=str, required=True)
    args.add_argument("--secret_key", type=str, required=True)
    args.add_argument("--tag", type=str, required=True)
    args.add_argument("--registry", type=str, required=True)
    args.add_argument("--repository", type=str, required=True)
    args.add_argument("--capacity_provider", type=str, required=True)
    
    config = args.parse_args()
    return config


if __name__ == "__main__":

    config = define_argparser()

    access_key = config.access_key
    secret_key = config.secret_key
    tag = config.tag
    registry = config.registry
    repository = config.repository
    capacity_provider = config.capacity_provider

    # Get latest task definition
    ecs_client = boto3.client(
        "ecs", 
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name=REGION
    )

    ecs_client.register_task_definition(
        family="demo-dashboard",
        networkMode="bridge",
        requiresCompatibilities=["EC2"],
        containerDefinitions=[
            {
                "name": "web",
                "image": f"{registry}/{repository}:{tag}",
                "cpu": 10,
                "memory": 300,
                "links": [
                    "redis:redis",
                ],
                "portMappings": [
                    {
                        "containerPort": 80,
                        "hostPort": 3000,
                        "protocol": "tcp"
                    },
                ],
                "dependsOn": [
                    {
                    "containerName": "redis",
                    "condition": "START"
                    }
                ],
                "command": [
                    "python", "manage.py", "runserver", "0.0.0.0:80"
                ]
            },
            {
                "name": "celery",
                "image": f"{registry}/{repository}:{tag}",
                "cpu": 10,
                "memory": 300,
                "links": [
                    "redis:redis",
                ],
                "dependsOn": [
                    {
                    "containerName": "redis",
                    "condition": "START"
                    }
                ],
                "command": [
                    "celery",  "-A", "pikurate.apps.taskapp.celery", "worker", "-B", "-l", "info"
                ]
            },
            {
                "name": "redis",
                "image": "redis:5.0.3",
                "cpu": 10,
                "memory": 300
            }
        ]
    )

    td_list = ecs_client.list_task_definitions(sort="ASC")
    td_latest = td_list.get("taskDefinitionArns")[-1]

    # Upload appspec.yaml for codedeploy
    s3_client = boto3.client(
        "s3", 
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name=REGION
    )

    appspec = appspec_tamplate(td_latest, capacity_provider)
    stream = io.BytesIO(appspec.encode("utf-8"))
    s3_client.upload_fileobj(stream, BUCKET, APPSPEC_NAME)

    # Create deployment
    codedeploy_client = boto3.client(
        "codedeploy", 
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name=REGION
    )
    codedeploy_client.create_deployment(
        revision={
            "revisionType": "S3",
            "s3Location": {
                "bucket": BUCKET,
                "key": APPSPEC_NAME,
                "bundleType": "YAML",
            }
        },
        applicationName=APPLICATION_NAME,
        deploymentGroupName=DEPLOYMNET_GROUP_NAME,
        description="CodeDeploy for pikurate dashboard backend server"
    )