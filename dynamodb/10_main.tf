
resource "aws_dynamodb_table" "obj" {

  ### Required
  name         = var.name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  ### Optional
  range_key              = var.range_key
  read_capacity          = var.read_capacity
  restore_date_time      = var.restore_date_time
  restore_source_name    = var.restore_source_name
  restore_to_latest_time = var.restore_to_latest_time
  stream_enabled         = var.stream_enabled
  stream_view_type       = var.stream_view_type
  table_class            = var.table_class
  tags                   = var.tags
  write_capacity         = var.write_capacity

  ### Dynamic Blocks
  dynamic "attribute" {
    for_each = var.attribute_defs
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_defs
    content {
      name               = local_secondary_index.value["name"]
      range_key          = local_secondary_index.value["range_key"]
      projection_type    = local_secondary_index.value["projection_type"]
      non_key_attributes = local_secondary_index.value["non_key_attributes"]
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_defs
    content {
      name               = global_secondary_index.value["name"]
      hash_key           = global_secondary_index.value["hash_key"]
      projection_type    = global_secondary_index.value["projection_type"]
      non_key_attributes = global_secondary_index.value["non_key_attributes"]
      range_key          = global_secondary_index.value["range_key"]
      read_capacity      = global_secondary_index.value["read_capacity"]
      write_capacity     = global_secondary_index.value["write_capacity"]
    }
  }

  dynamic "point_in_time_recovery" {
    for_each = var.point_in_time_recovery_defs
    content {
      enabled = point_in_time_recovery.value["enabled"]
    }
  }

  dynamic "replica" {
    for_each = var.replica_defs
    content {
      region_name            = replica.value["region_name"]
      kms_key_arn            = replica.value["kms_key_arn"]
      point_in_time_recovery = replica.value["point_in_time_recovery"]
      propagate_tags         = replica.value["propagate_tags"]
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.server_side_encryption_defs
    content {
      enabled     = server_side_encryption.value["enabled"]
      kms_key_arn = server_side_encryption.value["kms_key_arn"]
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_defs
    content {
      enabled        = ttl.value["enabled"]
      attribute_name = ttl.value["attribute_name "]
    }
  }

}
