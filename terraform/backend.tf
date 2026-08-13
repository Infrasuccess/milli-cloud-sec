terraform {
  backend "s3" {
    bucket       = "milli-cloud-sec-tf-state-419467346711"
    key          = "devsec/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}