# terraform-action

Custom action to handle multi-level terraform repositories.

## Inputs

### `TFPATH`

**Required** The path/to/terraform configuration files. Does not default.

### `REGION`

**Required** The AWS region to perform Terraform commands against. Does not default.

### `ACTION`

**Required** The action for Terraform to perform. Does not default.

### `GITHUB_API_TOKEN`

**Required** Used for authenticating to the GitHub API for commenting on PRs. Currently, if destructive actions are present in the Terraform plan, the action will comment such on the PR with reference to the `$TFPATH` to ensure these changes are intended.

### `REPO_OWNER`

**Required** Used for dynamically building the PR URL.

### `REPO_NAME`

**Required** Used for dynamically building the PR URL.

## Example usage

```yaml
uses: isabey-cogni/terraform-action@v1
with:
  TFPATH: 'staging/iam/'
  REGION: 'us-east-1'
  ACTION: 'plan'
  GITHUB_API_TOKEN: ${{ secrets.GITHUB_API_TOKEN }}
  REPO_OWNER: 'isabey'
  REPO_NAME: 'terraform-action'
```
