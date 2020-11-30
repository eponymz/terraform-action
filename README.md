# terraform-action

Custom action to handle multi-level terraform repositories.

### Things to note
1. This repository does **_NOT_** handle configuring your AWS credentials for terraform.
    1. This project assumes that AWS credentials are present when executing Terraform commands.
    2. [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials) can be used to configured credentials within a job.

## Inputs
> Click input variable to nav to description

| Input | Required |
| ----- | -------- |
| [`TFPATH`](#TFPATH) | yes |
| [`REGION`](#REGION) | yes |
| [`ACTION`](#ACTION) | yes |
| [`ACCESS_TOKEN`](#ACCESS_TOKEN) | yes |
| [`REPO_OWNER`](#REPO_OWNER) | yes |
| [`REPO_NAME`](#REPO_NAME) | yes |
| [`IS_MANUAL`](#IS_MANUAL) | optional |
| [`SLACK_WEBHOOK_URL`](#SLACK_WEBHOOK_URL) | required if `IS_MANUAL` is `true` |

---

## Descriptions
### `TFPATH`
The path/to/terraform configuration files. Does not default.

### `REGION`
The AWS region to perform Terraform commands against. Does not default.

### `ACTION`
The action for Terraform to perform. Does not default.

### `ACCESS_TOKEN`
Used for authenticating to the GitHub API for commenting on PRs. Currently, if destructive actions are present in the Terraform plan, the action will comment such on the PR with reference to the `$TFPATH` and a link to the execution of the workflow to ensure these changes are intended.

### `REPO_OWNER`
Used for dynamically building the PR URL.

### `REPO_NAME`
Used for dynamically building the PR URL.

### `IS_MANUAL`
Used for internal handling of the destructive plan function.

### `SLACK_WEBHOOK_URL`
Used in tandem with `IS_MANUAL`. Will send the destructive plan message to Slack if present.

## Example usage

- Non-manual execution.
```yaml
uses: isabey-cogni/terraform-action@latest
with:
  TFPATH: 'staging/iam/'
  REGION: 'us-east-1'
  ACTION: 'plan'
  ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
  REPO_OWNER: 'isabey'
  REPO_NAME: 'terraform-action'
```

- Manual execution.
```yaml
uses: isabey-cogni/terraform-action@latest
with:
  TFPATH: 'staging/iam/'
  REGION: 'us-east-1'
  ACTION: 'plan'
  ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
  REPO_OWNER: 'isabey'
  REPO_NAME: 'terraform-action'
  IS_MANUAL: true
  SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```
