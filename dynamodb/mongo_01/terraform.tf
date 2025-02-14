#################################################################################################################
### Terraform Config
terraform {
  required_version = "~>0.12"

  backend "s3" {
    bucket         = "tfstate.prod.te-general.com"
    key            = "prod/db/mongo_01.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = var.tfAwsRegion
}

### Terraform Config
#################################################################################################################
#################################################################################################################
### Remote State Data Objects

data "terraform_remote_state" "core_0" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/0.tfstate"
    region = var.tfAwsRegion
  }
}

data "terraform_remote_state" "core_1" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/1.tfstate"
    region = var.tfAwsRegion
  }
}

data "terraform_remote_state" "core_2" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/2.tfstate"
    region = var.tfAwsRegion
  }
}

data "terraform_remote_state" "core_3" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/3.tfstate"
    region = var.tfAwsRegion
  }
}


### Remote State Data Objects
#################################################################################################################
