# milli-cloud-sec (devsec)

Personal AWS DevSecOps lab using Terraform + GitHub Actions with SAST, DAST, and SCA.

## Goals
- Simulate cloud security in a production style environment
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
  - uploads tfsec, Checkov, Trivy, and Semgrep SARIF results to the GitHub Security dashboard
  - requires GitHub code scanning to be enabled in the repository settings for SARIF uploads to appear in the Security dashboard
  - uploads the ZAP baseline HTML report as the `zap-report` workflow artifact when `DAST_TARGET_URL` is set and reachable
- `terraform-apply.yml`
  - configures AWS credentials
  - checks the Terraform backend exists
  - runs Terraform fmt, init, validate, plan, and apply
- `terraform-destroy.yml`
  - requires typing `DESTROY` on manual dispatch
  - destroys the lab using the configured remote backend

## GitHub Security Features
- Code scanning is populated by `ci-security.yml` for tfsec, Checkov, Trivy, and Semgrep
- DAST is run by ZAP in `ci-security.yml` and published as the `zap-report` workflow artifact when the target is reachable
- Dependabot is configured in `.github/dependabot.yml` for:
  - GitHub Actions dependencies
  - Terraform providers and modules under `terraform/`

## Cost Control
- Uses EC2 stop/start schedules
- Includes AWS budget alerts
- Destroy when not using the lab
