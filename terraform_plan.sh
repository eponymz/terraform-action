#!/bin/bash

TFPATH=$1
REGION=$2
ACTION=$3
PR_NUMBER=$("$GITHUB_EVENT_PATH" | jq -r ".pull_request.number")
REPO_OWNER="cogni-dev"
REPO_NAME="infra"
PR_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${PR_NUMBER}/comments"

destructive_plan () {
  COMMENT_BODY='{"body": "Destroy actions present in '$1'. Please review the related workflow execution to ensure this is intended!"}'
  echo " Commenting on PR."
  curl -s -H "Authorization: token ${GITHUB_API_TOKEN}" -X POST -d $COMMENT_BODY $PR_URL
  EXITCODE=0
}

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
    ACTION="plan -lock=false -detailed-exitcode -out=plan.tmp"
  ;;
  apply)
    ACTION="apply -auto-approve"
  ;;
  *)
    echo "action not specificed, defaulting to plan"
    ACTION="plan -lock=false -detailed-exitcode -out=plan.tmp"
  ;;
esac

echo "ACTION is '$ACTION'"

cd $TFPATH

terraform init

terraform fmt -check
[ $? -ne 0 ] && echo "Unformatted Terraform files found. Please run 'terraform fmt' from within '$TFPATH' and push the changes. Exiting.." && exit 1

terraform validate
[ $? -ne 0 ] && echo "Terraform validation failed. Please run 'terraform validate' locally and resolve the issues mentioned. Exiting.." && exit 1

terraform $ACTION

ACTION_EXIT_CODE=$?

if [ $ACTION_EXIT_CODE -eq 1 ]; then
  EXITCODE=1
elif [ $ACTION_EXIT_CODE -eq 2 ] && [[ $ACTION =~ plan ]]; then
  for i in $(tf show -json plan.tmp | jq -r ".resource_changes[].change.actions[]"); do
    if [ $i = "delete" ]; then
      DESTRUCTIVE_PLAN=true
      break
    fi
  done

  [ $DESTRUCTIVE_PLAN = "true" ] && destructive_plan $TFPATH
else
  EXITCODE=0
fi

exit $EXITCODE
