#!/bin/bash

TFPATH=$1
REGION=$2
ACTION=$3
ACCESS_TOKEN=$4
REPO_OWNER=$5
REPO_NAME=$6
IS_MANUAL=$7
SLACK_WEBHOOK_URL=$8

PR_NUMBER=$(cat $GITHUB_EVENT_PATH | jq -r ".pull_request.number")
PR_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${PR_NUMBER}/comments"
ACTIONS_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/actions"

SLACK_MESSAGE_BODY='{"text":"Destroy actions present in \"'$TFPATH'\". Please review the workflow execution at '$ACTIONS_URL' to ensure this is intended!"}'
COMMENT_BODY='{"body": "Destroy actions present in \"'$TFPATH'\". Please review the workflow execution to ensure this is intended!"}'

destructive_plan () {
  if [[ $IS_MANUAL = true ]]; then
    echo "Sending Slack Message."
    CURL_COMMAND=$(curl -sSw "%{response_code}" -H "Content-type: application/json" -X POST -d "$SLACK_MESSAGE_BODY" $SLACK_WEBHOOK_URL)
  else
    echo "Commenting on PR at '$PR_URL'."
    CURL_COMMAND=$(curl -sSw "%{response_code}" -H \"Authorization: token ${ACCESS_TOKEN}\" -X POST -d \"$COMMENT_BODY\" $PR_URL)
  fi
  echo "$CURL_COMMAND"
  if test $response_code != 200; then
    EXITCODE=1
    echo "Failed to notify of destructive changes. Failing job."
  else
    EXITCODE=0
  fi
  unset DESTRUCTIVE_PLAN
}

if [ -z "$REGION" ] || [ -z "$TFPATH" ] || [ -z "$ACTION" ] || [ -z "$ACCESS_TOKEN" ] || [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ] ; then
  echo "Please set all variables"
  echo "Region: $REGION"
  echo "Path: $TFPATH"
  echo "Action: $ACTION"
  echo "Repo Owner: $REPO_OWNER"
  echo "Repo Name: $REPO_NAME"
  [ -z "$ACCESS_TOKEN" ] && echo "Access Token: 'null'"
  exit 1
fi

if [ -z "$IS_MANUAL" ]; then
  echo "Not manual execution"
else
  echo "Manual execution"
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
echo "Executing 'terraform $ACTION' for PR: #$PR_NUMBER."

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
  echo "Changes present in the current terraform plan. Evaluating for destructive changes."
  for i in $(terraform show -json plan.tmp | jq -r ".resource_changes[].change.actions[]"); do
    if [ $i = "delete" ]; then
      DESTRUCTIVE_PLAN=true
      break
    fi
  done

  if [[ $DESTRUCTIVE_PLAN = true ]]; then
    echo "Destructive changes detected!"
    destructive_plan
  else
    echo "No destructive changes detected!"
    EXITCODE=0
  fi
else
  EXITCODE=0
fi

exit $EXITCODE
