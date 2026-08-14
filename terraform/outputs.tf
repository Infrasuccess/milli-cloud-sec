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

# Elastic IP outputs (from elastic_ips.tf resources)
output "target_static_ip" {
  description = "Static IP address of target (DVWA)"
  value       = try(aws_eip.target.public_ip, null)
}

output "scanner_static_ip" {
  description = "Static IP address of scanner/jump host"
  value       = try(aws_eip.scanner.public_ip, null)
}

output "target_eip_allocation_id" {
  description = "Allocation ID of target EIP (for manual management)"
  value       = try(aws_eip.target.id, null)
}

output "scanner_eip_allocation_id" {
  description = "Allocation ID of scanner EIP (for manual management)"
  value       = try(aws_eip.scanner.id, null)
}

