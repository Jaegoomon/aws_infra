import boto3
import io


ACCESS_KEY_ID = ""
SECRET_ACCESS_KEY = ""
APPLICATION_NAME="ecs-deploy-app"
DEPLOYMNET_GROUP_NAME = "ecs-deploy-group"
BUCKET = "pikurate-bluegreen-bucket"
APPSPEC_NAME = "appspec.yaml"

appspec_tamplate = lambda task_definition: f"""
version: 1.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "{task_definition}"
        LoadBalancerInfo:
          ContainerName: "web"
          ContainerPort: 80
"""


if __name__ == "__main__":

    # Get latest task definition
    ecs_client = boto3.client(
        "ecs", 
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=SECRET_ACCESS_KEY
    )

    td_list = ecs_client.list_task_definitions(sort="ASC")
    td_latest = td_list.get("taskDefinitionArns")[-1]

    # Upload appspec.yaml for codedeploy
    s3_client = boto3.client(
        "s3", 
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=SECRET_ACCESS_KEY
    )

    appspec = appspec_tamplate(td_latest)
    stream = io.BytesIO(appspec.encode("utf-8"))
    s3_client.upload_fileobj(stream, BUCKET, APPSPEC_NAME)

    # Create deployment
    codedeploy_client = boto3.client(
        "codedeploy", 
        aws_access_key_id=ACCESS_KEY_ID,
        aws_secret_access_key=SECRET_ACCESS_KEY
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