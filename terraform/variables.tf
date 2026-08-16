# This is the Terraform configuration file for defining input variables used across the project. It includes variables for AWS region, project details, VPC and subnet configuration, EC2 instance settings, allowed ingress CIDR, SSH access, budget settings, scheduling, and Qualys integration.
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "milli-cloud-sec"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "devsec"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "Security Lab"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.40.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (requested t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Optional EC2 key pair name"
  type        = string
  default     = null
}

variable "allowed_ingress_cidr" {
  description = "Allowed ingress CIDR for HTTP/HTTPS to target"
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_ssh" {
  description = "Enable SSH 22 ingress to the target and scanner from the named IPs in security_groups.tf"
  type        = bool
  default     = false
}

variable "budget_limit_usd" {
  description = "Monthly AWS budget in USD"
  type        = string
  default     = "25"
}

variable "notification_email" {
  description = "Email for budget alerts"
  type        = string
}

variable "start_cron_utc" {
  description = "Start schedule (UTC) for both instances"
  type        = string
  default     = "cron(0 12 ? * MON-FRI *)"
}

variable "stop_cron_utc" {
  description = "Stop schedule (UTC) for both instances"
  type        = string
  default     = "cron(0 1 ? * MON-FRI *)"
}

variable "enable_qualys_cspm" {
  description = "Enable Qualys CSPM connector integration"
  type        = bool
  default     = false
}

variable "qualys_account_id" {
  description = "Qualys AWS Account ID for assume role (from Qualys console)"
  type        = string
  default     = ""
}

variable "qualys_external_id" {
  description = "Qualys External ID for enhanced security (from Qualys connector setup)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_qualys_iac_posture" {
  description = "Enable Qualys IaC Posture scanning for Terraform and CloudFormation"
  type        = bool
  default     = false
}
