output "target_public_ip" {
  value       = aws_instance.target.public_ip
  description = "Public IP of DAST target"
}

output "target_url" {
  value       = "http://${aws_instance.target.public_ip}"
  description = "DVWA target URL"
}

output "scanner_public_ip" {
  value       = aws_instance.scanner.public_ip
  description = "Public IP of scanner host"
}

output "instance_ids" {
  value = {
    target  = aws_instance.target.id
    scanner = aws_instance.scanner.id
  }
}
