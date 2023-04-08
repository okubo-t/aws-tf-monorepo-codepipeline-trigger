import json
import boto3
import os

codepipeline = boto3.client('codepipeline')
ssm = boto3.client('ssm')

PARAMETER_NAME = os.environ['PARAMETER_NAME']
  
def lambda_handler(event, context):

    project_pipelines = load_project_pipelines_from_parameter_store(PARAMETER_NAME)

    commit_id = event['detail']['commitId']
    repository_name = event['detail']['repositoryName']
    changed_files = get_changed_files(repository_name, commit_id)

    for project_dir, pipeline_name in project_pipelines.items():
        if any(file.startswith(project_dir) for file in changed_files):
            start_pipeline(pipeline_name)

def load_project_pipelines_from_parameter_store(parameter_name):
    response = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
    parameter_value = response['Parameter']['Value']
    project_pipelines = json.loads(parameter_value)
    return project_pipelines

def get_changed_files(repository_name, commit_id):
    codecommit = boto3.client('codecommit')
    response = codecommit.get_commit(
        repositoryName=repository_name,
        commitId=commit_id
    )

    commit = response['commit']
    parent_commit_id = commit['parents'][0]

    response = codecommit.get_differences(
        repositoryName=repository_name,
        afterCommitSpecifier=commit_id,
        beforeCommitSpecifier=parent_commit_id
    )

    changed_files = [difference['afterBlob']['path'] for difference in response['differences']]
    return changed_files

def start_pipeline(pipeline_name):
    response = codepipeline.start_pipeline_execution(name=pipeline_name)
    print(f"Started pipeline: {pipeline_name}, executionId: {response['pipelineExecutionId']}")
