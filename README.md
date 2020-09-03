# terraform-action

Custom action to handle multi-level terraform repositories.

## Inputs

### `TFPATH`

**Required** The path/to/terraform configuration files. Does not default.

### `REGION`

**Required** The AWS region to perform Terraform commands against. Does not default.

### `ACTION`

**Required** The action for Terraform to perform. Does not default.

### `ACCESS_TOKEN`

**Required** Used for authenticating to the GitHub API for commenting on PRs. Currently, if destructive actions are present in the Terraform plan, the action will comment such on the PR with reference to the `$TFPATH` to ensure these changes are intended.

### `REPO_OWNER`

**Required** Used for dynamically building the PR URL.

### `REPO_NAME`

**Required** Used for dynamically building the PR URL.

### `IS_MANUAL`

**Optional** Used for internal handling of the destructive plan function.

### `SLACK_WEBHOOK_URL`

**Optional** Used in tandem with `IS_MANUAL`. Will send the destructive plan message to Slack if present.

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
