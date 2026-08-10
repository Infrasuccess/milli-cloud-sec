data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "default_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "target_sg" {
  name        = "${var.project_name}-${var.environment}-target-sg"
  description = "Target SG for vulnerable app lab"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP for DVWA / DAST target"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  ingress {
    description = "HTTPS (optional)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ingress_cidr]
  }

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH (optional)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ingress_cidr]
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "scanner_sg" {
  name        = "${var.project_name}-${var.environment}-scanner-sg"
  description = "Scanner/jump host SG"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH (optional)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ingress_cidr]
    }
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
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
}

resource "aws_instance" "target" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.target_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data_target.sh.tpl", {})

  tags = {
    Name = "${var.project_name}-${var.environment}-target"
    Role = "dast-target"
  }
}

resource "aws_instance" "scanner" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.scanner_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data_scanner.sh.tpl", {
    target_ip = aws_instance.target.public_ip
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-scanner"
    Role = "security-scanner"
  }
}

resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-${var.environment}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
  }
}

resource "aws_iam_role" "events_invoke_ssm_role" {
  name = "${var.project_name}-${var.environment}-events-invoke-ssm-role"

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

resource "aws_cloudwatch_event_rule" "start_rule" {
  name                = "${var.project_name}-${var.environment}-start-ec2"
  schedule_expression = var.start_cron_utc
}

resource "aws_cloudwatch_event_rule" "stop_rule" {
  name                = "${var.project_name}-${var.environment}-stop-ec2"
  schedule_expression = var.stop_cron_utc
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_rule.name
  target_id = "StartEC2Instances"
  arn       = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:automation-definition/AWS-StartEC2Instance:$DEFAULT"
  role_arn  = aws_iam_role.events_invoke_ssm_role.arn

  input = jsonencode({
    DocumentName = "AWS-StartEC2Instance"
    Parameters = {
      InstanceId = [
        aws_instance.target.id,
        aws_instance.scanner.id
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_rule.name
  target_id = "StopEC2Instances"
  arn       = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:automation-definition/AWS-StopEC2Instance:$DEFAULT"
  role_arn  = aws_iam_role.events_invoke_ssm_role.arn

  input = jsonencode({
    DocumentName = "AWS-StopEC2Instance"
    Parameters = {
      InstanceId = [
        aws_instance.target.id,
        aws_instance.scanner.id
      ]
    }
  })
}
