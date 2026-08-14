# milli-cloud-sec (devsec)

Personal AWS DevSecOps lab using Terraform + GitHub Actions with SAST, DAST, and SCA.

## Goals
- Learn cloud security hands-on
- Run a lightweight AWS lab with:
  - 2 EC2 instances (`t2.micro`)
  - RHEL 9 target host running DVWA in Docker
  - RHEL 9 scanner/jump host
- Integrate security controls in CI/CD
- Keep monthly cost low with stop/start scheduling + budget alerts

## Security Tooling in CI/CD
- SAST: Semgrep
- IaC security: tfsec, Checkov
- Filesystem and dependency scanning: Trivy
- DAST: OWASP ZAP baseline scan (when `DAST_TARGET_URL` is set and reachable)

## Quick Start
1) Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars`
2) Edit at least:
   - `notification_email`
   - `key_name` if you want SSH access
   - `enable_ssh` if you want the named SSH rules enabled
3) Ensure the remote Terraform backend already exists:
   - S3 bucket: `milli-cloud-sec-tf-state-419467346711`
   - DynamoDB table: `milli-cloud-sec-tf-locks`
4) Run:
   - `terraform -chdir=terraform init`
   - `terraform -chdir=terraform plan`
   - `terraform -chdir=terraform apply`

## Terraform Layout
- `providers.tf`, `versions.tf`, `variables.tf`, `outputs.tf` hold shared provider, version, input, and output definitions
- `backend.tf` configures the S3 remote state backend and DynamoDB locking
- `data.tf` contains shared AWS data sources
- `network.tf` defines the VPC, subnet, internet gateway, and routing
- `security_groups.tf` defines target and scanner security groups, plus optional named SSH ingress rules for the target
- `iam.tf` defines EC2 SSM access and EventBridge-to-SSM IAM permissions
- `ec2.tf` defines the target and scanner EC2 instances
- `budget.tf` defines the monthly AWS budget and alert notifications
- `scheduler.tf` defines the start/stop EventBridge schedules for both EC2 instances
- `user_data_target.sh.tpl` installs Docker on RHEL and starts DVWA on the target host
- `user_data_scanner.sh.tpl` installs scanner utilities and Docker on RHEL and writes the target URL for the scanner host

## GitHub Secrets
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- BUDGET_EMAIL
- DAST_TARGET_URL (optional)

## GitHub Actions Workflows
- `ci-security.yml`
  - runs Terraform format and validate checks
  - runs Semgrep, tfsec, Checkov, and Trivy
  - runs ZAP baseline only when `DAST_TARGET_URL` is set and reachable
- `terraform-apply.yml`
  - configures AWS credentials
  - checks the Terraform backend exists
  - runs Terraform fmt, init, validate, plan, and apply
- `terraform-destroy.yml`
  - requires typing `DESTROY` on manual dispatch
  - destroys the lab using the configured remote backend

## Cost Control
- Uses EC2 stop/start schedules
- Includes AWS budget alerts
- Destroy when not using the lab
