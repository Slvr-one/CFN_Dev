#!/usr/bin/env bash
set -eux


SsName="MyStackSet"

# Ensure that you have the correct AWS credentials configured.
# Require:
# name of the stack,
# the parameters file name,
# the template name,
# changeset condition, 
# the region name.

if [ $# -ne 5 ]; then
    echo "Enter stack name, parameters file name, template file name to create, set changeset value (true or false), and enter region name. "
    exit 0
else
    STACK_NAME=$1
    PARAMETERS_FILE_NAME=$2
    TEMPLATE_NAME=$3
    CHANGESET_MODE=$4
    REGION=$5
fi

if [[ "cfn/"$TEMPLATE_NAME != *.yaml ]]; then
    echo "CloudFormation template $TEMPLATE_NAME does not exist. Make sure the extension is *.yaml and not (*.yml)"
    exit 0
fi

if [[ "parameters/"$PARAMETERS_FILE_NAME != *.properties ]]; then
    echo "CloudFormation parameters $PARAMETERS_FILE_NAME does not exist"
    exit 0
fi

if [[ $CHANGESET_MODE == "true" ]] || [[ $CHANGESET_MODE == "True" ]]; then
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file cloudformation/$TEMPLATE_NAME \
    --parameter-overrides file://parameters/$PARAMETERS_FILE_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
else
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file cloudformation/$TEMPLATE_NAME \
    --parameter-overrides file://parameters/$PARAMETERS_FILE_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION \
    --no-execute-changeset
fi

aws cloudformation --validate-template --template-body  file://jenkins_server.yaml

aws cloudformation create-stack-set \
  --stack-set-name $SsName \
  --template-body file://jenkins_server.yaml \
  --capabilities CAPABILITY_IAM


aws cloudformation create-stack-instances \
  --stack-set-name $SsName \
  --accounts AccountId1 AccountId2 \
  --regions us-west-2 us-east-1

aws cloudformation update-stack-set \
  --stack-set-name $SsName \
  --operation-preferences FailureToleranceCount=0,MaxConcurrentCount=1

aws cloudformation describe-stack-set-operation \
  --stack-set-name $SsName \
  --operation-id OperationId