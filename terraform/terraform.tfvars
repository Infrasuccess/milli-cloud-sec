aws_region           = "us-east-1"
project_name         = "milli-cloud-sec"
environment          = "devsec"
owner                = "Security Lab"
instance_type        = "t2.micro"
key_name             = "Milli-SecLab-Keypair"
allowed_ingress_cidr = "0.0.0.0/0"
enable_ssh           = true
notification_email   = "guysbow@gmail.com"
budget_limit_usd     = "25"

start_cron_utc       = "cron(0 12 ? * MON-FRI *)"
stop_cron_utc        = "cron(0 1 ? * MON-FRI *)"

# Qualys CSPM Integration
# Get these values from Qualys portal: Modules → Total Cloud → Connectors → New AWS Connector
enable_qualys_cspm = true
qualys_account_id  = "148141692175"
qualys_external_id = "qta-9a7b3f2c1e4d8a5b"
