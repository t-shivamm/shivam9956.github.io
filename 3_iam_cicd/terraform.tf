#################################################################################################################
### Terraform Config
terraform {
  required_version = "~>0.13"

  backend "s3" {
    bucket         = "tfstate.prod.te-general.com"
    key            = "prod/core/3_iam_cicd.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  version = "~>3.0"
  region  = var.tfAwsRegion
}

### Terraform Config
#################################################################################################################
