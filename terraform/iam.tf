resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ssm-role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-ssm-profile"
  }
}

resource "aws_iam_role" "events_invoke_ssm_role" {
  name = "${var.project_name}-${var.environment}-events-invoke-ssm-role"

  tags = {
    Name = "${var.project_name}-${var.environment}-events-invoke-ssm-role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "events_invoke_ssm_policy" {
  name = "${var.project_name}-${var.environment}-events-invoke-ssm-policy"
  role = aws_iam_role.events_invoke_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "ssm:StartAutomationExecution"
      Resource = "*"
    }]
  })
}
