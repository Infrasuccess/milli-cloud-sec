# Qualys Total Cloud (CSPM) - AWS IAM Permissions
# Enables Qualys to scan AWS infrastructure for security posture and compliance
# Required for:
# - Cloud Security Posture Management (CSPM) scanning
# - Infrastructure assessment
# - Compliance monitoring (CIS, PCI-DSS, etc.)
# - Asset discovery and inventory
# - IaC Posture scanning (Terraform, CloudFormation templates)
#
# Variables defined in variables.tf:
# - enable_qualys_cspm (bool, default: false)
# - enable_qualys_iac_posture (bool, default: false)
# - qualys_account_id (string, from Qualys console)
# - qualys_external_id (string, from Qualys console, sensitive)

# Qualys CSPM IAM Policy - read-only permissions for scanning
# Includes CloudFormation, Terraform state, and IaC Posture permissions
resource "aws_iam_policy" "qualys_cspm_policy" {
  count       = var.enable_qualys_cspm ? 1 : 0
  name        = "${var.project_name}-${var.environment}-qualys-cspm-policy"
  description = "Qualys CSPM read-only permissions for cloud security posture and IaC scanning"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "QualysEC2Permissions"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:GetFlow*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysS3Permissions"
        Effect = "Allow"
        Action = [
          "s3:GetBucket*",
          "s3:GetObject*",
          "s3:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysIAMPermissions"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysVPCPermissions"
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysRDSPermissions"
        Effect = "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysELBPermissions"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysCloudWatchPermissions"
        Effect = "Allow"
        Action = [
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysCloudTrailPermissions"
        Effect = "Allow"
        Action = [
          "cloudtrail:Describe*",
          "cloudtrail:List*",
          "cloudtrail:GetTrailStatus"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysKMSPermissions"
        Effect = "Allow"
        Action = [
          "kms:Describe*",
          "kms:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysSecretsManagerPermissions"
        Effect = "Allow"
        Action = [
          "secretsmanager:List*",
          "secretsmanager:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysSystemsManagerPermissions"
        Effect = "Allow"
        Action = [
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysAutoScalingPermissions"
        Effect = "Allow"
        Action = [
          "autoscaling:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysConfigPermissions"
        Effect = "Allow"
        Action = [
          "config:Describe*",
          "config:Get*",
          "config:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysCloudFormationPermissions"
        Effect = "Allow"
        Action = [
          "cloudformation:Describe*",
          "cloudformation:GetTemplate*",
          "cloudformation:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "QualysS3StatePermissions"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::*-terraform-state*",
          "arn:aws:s3:::*-terraform-state*/*"
        ]
      },
      {
        Sid    = "QualysIaCPosturePermissions"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for Qualys to assume
resource "aws_iam_role" "qualys_cspm_role" {
  count       = var.enable_qualys_cspm ? 1 : 0
  name        = "${var.project_name}-${var.environment}-qualys-cspm-role"
  description = "Role for Qualys CSPM connector to assume"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.qualys_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = var.qualys_external_id != "" ? {
          StringEquals = {
            "sts:ExternalId" = var.qualys_external_id
          }
        } : null
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-${var.environment}-qualys-cspm-role"
    Service = "Qualys"
    Purpose = "CSPM and IaC Posture"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "qualys_cspm_policy_attachment" {
  count      = var.enable_qualys_cspm ? 1 : 0
  role       = aws_iam_role.qualys_cspm_role[0].name
  policy_arn = aws_iam_policy.qualys_cspm_policy[0].arn
}

# Outputs for Qualys connector configuration
output "qualys_role_arn" {
  description = "ARN of the Qualys CSPM role (use in Qualys connector setup)"
  value       = var.enable_qualys_cspm ? aws_iam_role.qualys_cspm_role[0].arn : null
}

output "qualys_role_name" {
  description = "Name of the Qualys CSPM role"
  value       = var.enable_qualys_cspm ? aws_iam_role.qualys_cspm_role[0].name : null
}

output "qualys_policy_arn" {
  description = "ARN of the Qualys CSPM policy"
  value       = var.enable_qualys_cspm ? aws_iam_policy.qualys_cspm_policy[0].arn : null
}

output "qualys_iac_posture_enabled" {
  description = "Whether Qualys IaC Posture scanning is enabled"
  value       = var.enable_qualys_iac_posture
}

