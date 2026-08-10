# milli-cloud-sec (devsec)

Personal AWS DevSecOps lab using Terraform + GitHub Actions with SAST, DAST, and SCA.

## Goals
- Learn cloud security hands-on
- Run a lightweight AWS lab with:
  - 2 EC2 instances (`t2.micro`)
  - Vulnerable web target for DAST testing
  - Scanner/jump host
- Integrate security controls in CI/CD
- Keep monthly cost low with stop/start scheduling + budget alerts

## Security Tooling in CI/CD
- SAST: Semgrep, tfsec
- SCA: Trivy, Syft, Grype
- DAST: OWASP ZAP baseline scan

## Quick Start
1) `cd terraform && cp terraform.tfvars.example terraform.tfvars`
2) Edit `notification_email` in `terraform.tfvars`
3) `terraform init && terraform plan && terraform apply`

## GitHub Secrets
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- BUDGET_EMAIL
- DAST_TARGET_URL

## Cost Control
- Uses EC2 stop/start schedules
- Includes AWS budget alerts
- Destroy when not using the lab
