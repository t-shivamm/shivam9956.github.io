

### Optional arguments in object variable type definition
# Variables of type objects have a restriction where all arguments must be defined explicitly.
# This issue tracks the feature request to make these attributes optional by taking a default value of null.
# https://github.com/hashicorp/terraform/issues/19898
# As a workaround we define optional atributes as type "any" so a null value can be used

variable "commonTags" {
  type        = map(string)
  description = "Tags that should be applied to every resource"
}

variable "basics" {
  type = object({
    bucket        = string,
    omitEnvName   = any,
    omitAccNo     = any,
    force_destroy = any,
    request_payer = any
  })
}

variable "versioning" {
  type = map(object({
    enabled    = any,
    mfa_delete = any,
  }))
  description = "Lookup the versioning argument of the aws_s3_bucket resource"
}

variable "logging" {
  type = map(object({
    target_bucket = string,
    target_prefix = any,
  }))
  description = "Lookup the logging argument of the aws_s3_bucket resource"
}

variable "lifecycle_rules" {
  type = map(map(object({
    enabled                                = string,
    id                                     = any,
    prefix                                 = any,
    tags                                   = any,
    abort_incomplete_multipart_upload_days = any,
    expiration-defs = map(object({
      date                         = any,
      days                         = any,
      expired_object_delete_marker = any
    })),
    transition-defs = map(object({
      date          = any,
      days          = any,
      storage_class = string,
    })),
    noncurrent_version_expiration-defs = map(object({
      days = string,
    })),
    noncurrent_version_transition-defs = map(object({
      days          = string,
      storage_class = string,
    })),
  })))
  description = "Lookup the lifecycle_rule argument of the aws_s3_bucket resource"
}

variable "replication_configuration" {
  type = map(object({
    role = string,
    rules-defs = map(object({
      status   = string,
      id       = any,
      priority = any,
      prefix   = any,
      destination-defs = map(object({
        bucket             = string,
        storage_class      = any,
        replica_kms_key_id = any,
        account_id         = any,
        access_control_translation-defs = map(object({
          owner = string,
        })),
      })),
      source_selection_criteria-defs = map(object({
        sse_kms_encrypted_objects-defs = map(object({
          enabled = string,
        }))
      })),
      filter-defs = map(object({
        prefix = any,
        tags   = any,
      })),
    })),
  }))
  description = "Lookup the replication_configuration argument of the aws_s3_bucket resource"
}

variable "website" {
  type = map(object({
    index_document           = string
    error_document           = any
    redirect_all_requests_to = any
    routing_rules            = any
  }))
  description = "Lookup the website argument of the aws_s3_bucket resource"
}


variable "public_access_block" {
  type = object({
    block_public_acls       = string
    block_public_policy     = string
    ignore_public_acls      = string
    restrict_public_buckets = string
  })
  description = "Lookup the aws_s3_bucket_public_access_block resource"
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}
