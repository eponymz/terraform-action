# terraform-action
Custom action to handle multi-level terraform repositories.

## Inputs

### `TFPATH`

**Required** The path/to/terraform configuration files. Does not default.

### `REGION`

**Required** The AWS region to perform Terraform commands against. Does not default.

### `ACTION`

**Required** The action for Terraform to perform. Does not default.

## Example usage

```yaml
uses: isabey-cogni/terraform-action@v1
with:
  TFPATH: 'staging/iam/'
  REGION: 'us-east-1'
  ACTION: 'plan'
```
