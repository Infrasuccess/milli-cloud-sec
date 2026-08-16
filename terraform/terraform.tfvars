aws_region           = "us-east-1"
project_name         = "milli-cloud-sec"
environment          = "devsec"
owner                = "Security Lab"
instance_type        = "t2.micro"
key_name             = "Milli-SecLab-Keypair"
allowed_ingress_cidr = "108.239.113.218/32"
enable_ssh           = true
notification_email   = "guysbow@gmail.com"
budget_limit_usd     = "25"

start_cron_utc = "cron(0 12 ? * MON-FRI *)"
stop_cron_utc  = "cron(0 1 ? * MON-FRI *)"

enable_qualys_cspm        = true
qualys_account_id         = "805950163170"
qualys_external_id        = "US3-9214256"
enable_qualys_iac_posture = true