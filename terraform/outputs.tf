output "target_public_ip" {
  value       = aws_instance.target.public_ip
  description = "Public IP of DAST target (dynamic)"
}

output "target_url" {
  value       = "http://${aws_instance.target.public_ip}"
  description = "DVWA target URL (use Elastic IP when available)"
}

output "scanner_public_ip" {
  value       = aws_instance.scanner.public_ip
  description = "Public IP of scanner host (dynamic)"
}

output "instance_ids" {
  value = {
    target  = aws_instance.target.id
    scanner = aws_instance.scanner.id
  }
}

# Elastic IP outputs (if enabled)
output "target_static_ip" {
  value       = try(aws_eip.target.public_ip, null)
  description = "Static Elastic IP for DVWA target (when allocated)"
}

output "scanner_static_ip" {
  value       = try(aws_eip.scanner.public_ip, null)
  description = "Static Elastic IP for scanner host (when allocated)"
}

# Qualys CSPM outputs (if enabled) - defined in qualys_cspm.tf
# Use 'terraform output qualys_role_arn' to retrieve the role ARN for Qualys connector setup
