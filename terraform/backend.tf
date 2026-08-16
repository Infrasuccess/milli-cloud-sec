# This is the backend configuration for Terraform. It specifies that the state file will be stored in an S3 bucket and that DynamoDB will be used for state locking to prevent concurrent modifications. The configuration includes the bucket name, key (path to the state file), AWS region, DynamoDB table name, and encryption settings.
terraform {
  backend "s3" {
    bucket         = "milli-cloud-sec-tf-state-419467346711"
    key            = "devsec/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "milli-cloud-sec-tf-locks"
    encrypt        = true
  }
}
