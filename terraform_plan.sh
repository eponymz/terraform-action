#!/bin/bash

TFPATH=$1
REGION=$2
ACTION=$3

if [ -z "$REGION" ] || [ -z "$TFPATH" ] || [ -z "$ACTION" ] ; then
  echo "Please set all variables"
  echo "Region: $REGION"
  echo "Path: $TFPATH"
  echo "Action: $ACTION"
  exit 1
fi

echo "Getting caller identity"
AWS_CALLER_IDENTITY=$(aws sts get-caller-identity --region $REGION)
ACCOUNT_NUMBER=$(echo $AWS_CALLER_IDENTITY | jq -r .Account)
ASSUMED_ROLE_ARN=$(echo $AWS_CALLER_IDENTITY | jq -r .Arn)
echo $AWS_CALLER_IDENTITY
echo "End getting caller identity"

if [ -z "$ACCOUNT_NUMBER" ] || [ -z "$ASSUMED_ROLE_ARN" ] ; then
  echo "Assume role failed"
  echo "ACCOUNT_NUMBER: $ACCOUNT_NUMBER"
  echo "ASSUMED_ROLE_ARN: $ASSUMED_ROLE_ARN"
  exit 1
fi

case $ACTION in
  plan)
    ACTION="plan -lock=false -detailed-exitcode"
  ;;
  apply)
    ACTION="apply -auto-approve"
  ;;
  *)
    echo "action not specificed, defaulting to plan"
    ACTION="plan -lock=false -detailed-exitcode"
  ;;
esac

echo "ACTION is '$ACTION'"

cd $TFPATH

terraform init
[ $? -ne 0 ] && echo "Terraform command failed. Exiting.."
terraform fmt -check
[ $? -ne 0 ] && echo "Terraform command failed. Exiting.."
terraform validate
[ $? -ne 0 ] && echo "Terraform command failed. Exiting.."
terraform $ACTION
ACTION_EXIT_CODE=$?

exit $ACTION_EXIT_CODE
