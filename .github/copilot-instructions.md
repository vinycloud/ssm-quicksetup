# AWS SSM Quick Setup Terraform POC

## Project Overview
This is a Terraform POC for deploying AWS Systems Manager (SSM) Quick Setup Configuration Manager with patch policy automation. The configuration sets up automated patch scanning across AWS resources using AWS-managed patch baselines.

## Architecture

### Core Components
- **SSM Quick Setup Configuration Manager** (`ssmquicksetup.tf`): Creates patch policy configuration with scheduled scanning
- **Dynamic Patch Baseline Mapping** (`locals.tf`): Automatically discovers and formats all AWS default patch baselines for different operating systems
- **AWS Context Data Sources** (`data.tf`): Retrieves account, partition, region, and patch baseline information

### Data Flow
1. `data.aws_ssm_patch_baselines` fetches all default AWS patch baselines for the region
2. `locals.selected_patch_baselines` transforms baseline data into QuickSetup's required JSON format (value/label/description/disabled structure)
3. SSM Configuration Manager consumes this as `SelectedPatchBaselines` parameter

### Key Design Pattern
The configuration uses **IAM role ARN composition** rather than hardcoded values:
```terraform
arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWS-QuickSetup-PatchPolicy-LocalAdministrationRole
```
This ensures the configuration works across different AWS partitions (commercial, GovCloud, China).

## Development Workflow

### Initialization & Deployment
```bash
terraform init
terraform plan -var-file=main.tfvars
terraform apply -var-file=main.tfvars
```

### Required AWS Permissions
- `ssm:CreateConfigurationManager`
- `ssm:GetPatchBaseline`, `ssm:DescribePatchBaselines`
- IAM role creation/management for QuickSetup execution roles

### Variable Configuration
Variables are defined in `variables.tf` and set via `main.tfvars`. Both `name` and `patch_policy_name` are required strings.

## Project-Specific Conventions

### File Organization
- **Standard Terraform structure**: `provider.tf`, `variables.tf`, `data.tf`, `locals.tf`, separate resource files
- **Resource files named by AWS service**: `ssmquicksetup.tf` contains SSM QuickSetup resources
- **Single tfvars file**: `main.tfvars` for all variable assignments

### Patch Policy Configuration
- **Scan-only mode**: `ConfigurationOptionsPatchOperation` set to "Scan" (not "Install")
- **Daily schedule**: `cron(0 1 * * ? *)` = 1 AM UTC daily scanning
- **Rate control**: 10% concurrency, 2% error threshold for scanning operations
- **Target scope**: Single account, single region, all resources (`TargetType: "*"`)

## Critical Notes

- **State file present**: `terraform.tfstate` exists in the repository (typically should be .gitignored for production)
- **Hardcoded region**: Provider configured for `us-east-1` only
- **AWS Provider version**: Pinned to `~> 6.0` (uses newer SSM QuickSetup resources)
- **Prerequisite roles**: Assumes AWS QuickSetup IAM roles already exist in the account (created automatically on first QuickSetup use)
