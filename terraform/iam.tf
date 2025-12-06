# IAM Role for QuickSetup Local Administration
resource "aws_iam_role" "quicksetup_local_admin" {
  name               = "AWS-QuickSetup-PatchPolicy-LocalAdministrationRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ssm.amazonaws.com",
            "cloudformation.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = {
    Name        = "AWS-QuickSetup-PatchPolicy-LocalAdministrationRole"
    Description = "Role for SSM QuickSetup Patch Policy Administration"
  }
}

# Inline policy for QuickSetup Administration
resource "aws_iam_role_policy" "quicksetup_admin_policy" {
  name = "QuickSetupAdminPolicy"
  role = aws_iam_role.quicksetup_local_admin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:CreateStackInstances",
          "cloudformation:CreateStackSet",
          "cloudformation:DeleteStack",
          "cloudformation:DeleteStackInstances",
          "cloudformation:DeleteStackSet",
          "cloudformation:DescribeStack*",
          "cloudformation:UpdateStack",
          "cloudformation:UpdateStackInstances",
          "cloudformation:UpdateStackSet",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWS-QuickSetup-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeDocument",
          "ssm:GetDocument",
          "ssm:CreateDocument",
          "ssm:DeleteDocument",
          "ssm:UpdateDocument",
          "ssm:CreateAssociation",
          "ssm:DeleteAssociation",
          "ssm:DescribeAssociation",
          "ssm:UpdateAssociation",
          "ssm:GetAutomationExecution",
          "ssm:StartAutomationExecution"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for QuickSetup Local Execution
resource "aws_iam_role" "quicksetup_local_exec" {
  name               = "AWS-QuickSetup-PatchPolicy-LocalExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWS-QuickSetup-PatchPolicy-LocalAdministrationRole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "AWS-QuickSetup-PatchPolicy-LocalExecutionRole"
    Description = "Role for SSM QuickSetup Patch Policy Execution"
  }
}

# Inline policy for QuickSetup Execution
resource "aws_iam_role_policy" "quicksetup_exec_policy" {
  name = "QuickSetupExecPolicy"
  role = aws_iam_role.quicksetup_local_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:CreateDocument",
          "ssm:UpdateDocument",
          "ssm:DeleteDocument",
          "ssm:CreateAssociation",
          "ssm:UpdateAssociation",
          "ssm:DeleteAssociation",
          "ssm:DescribeAssociation",
          "ssm:GetAutomationExecution",
          "ssm:StartAutomationExecution",
          "ssm:GetPatchBaseline",
          "ssm:DescribePatchBaselines",
          "ssm:ListDocuments",
          "ssm:ListDocumentVersions",
          "ssm:DescribeDocumentPermission",
          "ssm:ModifyDocumentPermission",
          "ssm:AddTagsToResource",
          "ssm:RemoveTagsFromResource",
          "ssm:ListTagsForResource",
          "ssm:CreateResourceDataSync",
          "ssm:DeleteResourceDataSync",
          "ssm:ListResourceDataSync",
          "ssm:UpdateServiceSetting",
          "ssm:GetServiceSetting",
          "ssm:ResetServiceSetting"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:CreateStackSet",
          "cloudformation:CreateStackInstances",
          "cloudformation:DeleteStack",
          "cloudformation:DeleteStackSet",
          "cloudformation:DeleteStackInstances",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackSet",
          "cloudformation:DescribeStackSetOperation",
          "cloudformation:DescribeStackInstance",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStackResource",
          "cloudformation:UpdateStack",
          "cloudformation:UpdateStackSet",
          "cloudformation:UpdateStackInstances",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate",
          "cloudformation:ListStacks",
          "cloudformation:ListStackSets",
          "cloudformation:ListStackInstances",
          "cloudformation:ListStackResources"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWS-QuickSetup-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketTagging",
          "s3:PutBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:PutLifecycleConfiguration",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketAcl",
          "s3:PutBucketLogging",
          "s3:GetBucketPolicy",
          "s3:GetBucketTagging",
          "s3:GetBucketVersioning",
          "s3:GetEncryptionConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketOwnershipControls",
          "s3:GetBucketAcl",
          "s3:GetBucketLogging",
          "s3:ListBucket",
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::aws-quicksetup-patchpolicy-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::aws-quicksetup-patchpolicy-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:ListTags",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:GetFunctionConfiguration",
          "lambda:PublishVersion"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:lambda:*:${data.aws_caller_identity.current.account_id}:function:AWS-QuickSetup-*",
          "arn:${data.aws_partition.current.partition}:lambda:*:${data.aws_caller_identity.current.account_id}:function:baseline-overrides-*",
          "arn:${data.aws_partition.current.partition}:lambda:*:${data.aws_caller_identity.current.account_id}:function:delete-name-tags-*",
          "arn:${data.aws_partition.current.partition}:lambda:*:${data.aws_caller_identity.current.account_id}:function:*-name-tags-*"
        ]
      }
    ]
  })
}
