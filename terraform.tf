

#################################################################################################################
### Terraform Config
terraform {
  required_version = "~>1.8.4"

  backend "s3" {
    bucket         = "tfstate.inte.te-general.com"
    key            = "inte/asg/accesskey.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
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

data "terraform_remote_state" "core_0_global" {
  backend = "s3"
  config = {
    bucket = "tfstate.common.te-general.com"
    key    = "env:/${var.commonTags.oEnvironment}/config/config-as-code.tfstate"
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

data "terraform_remote_state" "core_4_log-aggregate" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/4_log-aggregate.tfstate"
    region = var.tfAwsRegion
  }
}

data "terraform_remote_state" "core_5_userdata_s3" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/core/5_userdata_s3.tfstate"
    region = var.tfAwsRegion
  }
}

data "terraform_remote_state" "db_stnd-au-mysql2" {
  backend = "s3"
  config = {
    bucket = var.roleVariables.tfStateBucketName
    key    = "${var.commonTags.oEnvironment}/db/stnd-au-mysql2.tfstate"
    region = var.tfAwsRegion
  }
}
### Remote State Data Objects
#################################################################################################################
