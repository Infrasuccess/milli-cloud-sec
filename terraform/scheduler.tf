resource "aws_cloudwatch_event_rule" "start_rule" {
  name                = "${var.project_name}-${var.environment}-start-ec2"
  schedule_expression = var.start_cron_utc

  tags = {
    Name = "${var.project_name}-${var.environment}-start-ec2"
  }
}

resource "aws_cloudwatch_event_rule" "stop_rule" {
  name                = "${var.project_name}-${var.environment}-stop-ec2"
  schedule_expression = var.stop_cron_utc

  tags = {
    Name = "${var.project_name}-${var.environment}-stop-ec2"
  }
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
