locals {
  envName = var.commonTags["oEnvironment"]

  # The bucket name will by default add the environment name and AWS account as suffixes
  # They can be explicitly be omitted
  bucketSuffixEnvName = var.basics.omitEnvName == "true" || var.basics.omitEnvName == true ? "" : "-${local.envName}"
  bucketSuffixAccNo   = var.basics.omitAccNo == "true" || var.basics.omitAccNo == true ? "" : "-${data.aws_caller_identity.current.account_id}"
  bucketName          = "${var.basics.bucket}${local.bucketSuffixEnvName}${local.bucketSuffixAccNo}"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {

  bucket = local.bucketName

  force_destroy = var.basics.force_destroy
  request_payer = var.basics.request_payer

  tags = merge(var.commonTags, { Name = local.bucketName })

  dynamic "versioning" {
    for_each = var.versioning
    content {
      enabled    = versioning.value.enabled
      mfa_delete = versioning.value.mfa_delete
    }
  }

  dynamic "logging" {
    for_each = var.logging
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  dynamic "website" {
    for_each = var.website
    content {
      index_document           = website.value.index_document
      error_document           = website.value.error_document
      redirect_all_requests_to = website.value.redirect_all_requests_to
      routing_rules            = website.value.routing_rules
    }
  }


  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules

    content {
      enabled                                = lifecycle_rule.value.enabled
      id                                     = lifecycle_rule.value.id
      prefix                                 = lifecycle_rule.value.prefix
      tags                                   = lifecycle_rule.value.tags
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      dynamic "expiration" {
        for_each = lifecycle_rule.value.expiration-defs
        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.transition-defs
        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration-defs
        content {
          days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transition-defs
        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

    }
  }

  dynamic "replication_configuration" {
    for_each = var.replication_configuration

    content {
      role = replication_configuration.value.role

      dynamic "rules" {
        for_each = replication_configuration.value.rules-defs
        content {
          status   = rules.value.status
          id       = rules.value.id
          priority = rules.value.priority
          prefix   = rules.value.prefix

          dynamic "destination" {
            for_each = rules.value.destination-defs
            content {
              bucket             = destination.value.bucket
              storage_class      = destination.value.storage_class
              replica_kms_key_id = destination.value.replica_kms_key_id
              account_id         = destination.value.account_id

              dynamic "access_control_translation" {
                for_each = destination.value.access_control_translation-defs
                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = rules.value.source_selection_criteria-defs
            content {
              dynamic "sse_kms_encrypted_objects" {
                for_each = source_selection_criteria.value.sse_kms_encrypted_objects-defs
                content {
                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          dynamic "filter" {
            for_each = rules.value.filter-defs
            content {
              prefix = filter.value.prefix
              tags   = filter.value.tags
            }
          }

        }
      }
    }
  }

}


resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.public_access_block["block_public_acls"]
  block_public_policy     = var.public_access_block["block_public_policy"]
  ignore_public_acls      = var.public_access_block["ignore_public_acls"]
  restrict_public_buckets = var.public_access_block["restrict_public_buckets"]
}
