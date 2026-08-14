terraform {
  backend "s3" {
    bucket         = "milli-cloud-sec-tf-state-419467346711"
    key            = "devsec/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "milli-cloud-sec-tf-locks"
    encrypt        = true
  }
}
