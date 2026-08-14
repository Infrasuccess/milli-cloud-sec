# Elastic IP addresses (static public IPs) for EC2 instances
# Cost: $0 when associated with running instance
#       $3.60/month when associated with stopped instance
#       $3.60/month when allocated but unassociated

resource "aws_eip" "target" {
  domain     = "vpc"
  instance   = aws_instance.target.id
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.project_name}-${var.environment}-target-eip"
    Role = "dast-target"
  }
}

resource "aws_eip" "scanner" {
  domain     = "vpc"
  instance   = aws_instance.scanner.id
  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.project_name}-${var.environment}-scanner-eip"
    Role = "security-scanner"
  }
}
