
##################### Primitive types - required #####################

variable "name" {
  type        = string
  description = "See aws_dynamodb_table documentation"
}
variable "billing_mode" {
  type        = string
  description = "See aws_dynamodb_table documentation"
}
variable "hash_key" {
  type        = string
  description = "See aws_dynamodb_table documentation"
}

##################### Primitive types - Optional #####################

variable "range_key" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "read_capacity" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "restore_date_time" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "restore_source_name" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "restore_to_latest_time" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "stream_enabled" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "stream_view_type" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "table_class" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "tags" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}
variable "write_capacity" {
  type        = any
  default     = null
  description = "See aws_dynamodb_table documentation"
}

##################### Dynamic Blocks - required #####################
# The optional attributes below will all need to be provided with a value of null if unused.
# In TF1.3+ we can make them optional - https://github.com/hashicorp/terraform/releases/tag/v1.3.0

variable "attribute_defs" {
  type = map(object({
    # Required
    name = string
    type = string
  }))
  description = <<EOF
    A map of "attribute" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

##################### Dynamic Blocks - Optional #####################
# The optional attributes below will all need to be provided with a value of null if unused.
# In TF1.3+ we can make them optional - https://github.com/hashicorp/terraform/releases/tag/v1.3.0

variable "local_secondary_index_defs" {
  type = map(object({
    # Required
    name            = string
    range_key       = string
    projection_type = string
    # Optional (nullable)
    non_key_attributes = any
  }))
  default     = {}
  description = <<EOF
    A map of "local_secondary_index" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

variable "global_secondary_index_defs" {
  type = map(object({
    # Required
    name            = string
    hash_key        = string
    projection_type = string
    # Optional (nullable)
    non_key_attributes = any
    range_key          = any
    read_capacity      = any
    write_capacity     = any
  }))
  default     = {}
  description = <<EOF
    A map of "global_secondary_index" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

variable "point_in_time_recovery_defs" {
  type = map(object({
    # Required
    enabled = string
  }))
  default     = {}
  description = <<EOF
    A map of "point_in_time_recovery" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

variable "replica_defs" {
  type = map(object({
    # Required
    region_name = string
    # Optional
    kms_key_arn            = any
    point_in_time_recovery = any
    propagate_tags         = any
  }))
  default     = {}
  description = <<EOF
    A map of "replica" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

variable "server_side_encryption_defs" {
  type = map(object({
    # Required
    enabled = string
    # Optional
    kms_key_arn = any
  }))
  default     = {}
  description = <<EOF
    A map of "server_side_encryption" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}

variable "ttl_defs" {
  type = map(object({
    # Required
    enabled        = string
    attribute_name = string
  }))
  default     = {}
  description = <<EOF
    A map of "ttl" block definitions.
      See aws_dynamodb_table documentation.
    The key is arbitrary.
  EOF
}
