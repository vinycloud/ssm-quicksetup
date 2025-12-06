resource "aws_ssmquicksetup_configuration_manager" "this" {
  name = var.name

  configuration_definition {
    local_deployment_administration_role_arn = aws_iam_role.quicksetup_local_admin.arn
    local_deployment_execution_role_name     = aws_iam_role.quicksetup_local_exec.name
    type                                     = "AWSQuickSetupType-PatchPolicy"

    parameters = {
      "ConfigurationOptionsPatchOperation" : "Scan",
      "ConfigurationOptionsScanValue" : "cron(0 1 * * ? *)",
      "ConfigurationOptionsScanNextInterval" : "false",
      "PatchBaselineRegion" : data.aws_region.current.region,
      "PatchBaselineUseDefault" : "default",
      "PatchPolicyName" : var.patch_policy_name,
      "SelectedPatchBaselines" : local.selected_patch_baselines,
      "OutputLogEnableS3" : "false",
      "RateControlConcurrency" : "10%",
      "RateControlErrorThreshold" : "2%",
      "IsPolicyAttachAllowed" : "false",
      "TargetAccounts" : data.aws_caller_identity.current.account_id,
      "TargetRegions" : data.aws_region.current.region,
      "TargetType" : "*"
    }
  }
}