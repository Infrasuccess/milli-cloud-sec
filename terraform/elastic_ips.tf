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

# Outputs: Reference these IPs in your scripts, DNS, firewall rules, etc.
output "target_static_ip" {
  description = "Static IP address of target (DVWA)"
  value       = aws_eip.target.public_ip
}

output "scanner_static_ip" {
  description = "Static IP address of scanner/jump host"
  value       = aws_eip.scanner.public_ip
}

output "target_eip_allocation_id" {
  description = "Allocation ID of target EIP (for manual management)"
  value       = aws_eip.target.id
}

output "scanner_eip_allocation_id" {
  description = "Allocation ID of scanner EIP (for manual management)"
  value       = aws_eip.scanner.id
}
