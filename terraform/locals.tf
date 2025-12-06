locals {  
  selected_patch_baselines = jsonencode({
    for baseline in data.aws_ssm_patch_baselines.this.baseline_identities : baseline.operating_system => {
      "value" : baseline.baseline_id
      "label" : baseline.baseline_name
      "description" : baseline.baseline_description
      "disabled" : !baseline.default_baseline
    }
  })
}