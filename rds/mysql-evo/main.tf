# Local variables
locals {
  envName = lower(var.commonTags["rEnvironmentName"])
  parameters = concat([
    {
      apply_method = "immediate"
      name         = "character_set_client"
      value        = "utf8"
    },
    {
      apply_method = "immediate"
      name         = "character_set_server"
      value        = "utf8"
    },
    {
      apply_method = "pending-reboot"
      name         = "slow_query_log"
      value        = "1"
    },
    {
      apply_method = "pending-reboot"
      name         = "long_query_time"
      value        = "60"
    },
    {
      apply_method = "pending-reboot"
      name         = "log_queries_not_using_indexes"
      value        = "0"
    },
    {
      apply_method = "pending-reboot"
      name         = "binlog_format" #needed for Database migration service
      value        = "ROW"
    },
    {
      apply_method = "immediate"
      name         = "log_output"
      value        = "FILE"
    }
  ], var.xtra_parameters)
}

resource "aws_db_subnet_group" "default" {
  count       = var.database_active
  name        = "${var.rds_instance_identifier}-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = var.aws_subnet_ids
}

resource "aws_db_instance" "default" {
  count                      = var.database_active
  identifier                 = var.rds_instance_identifier
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  engine                     = "mysql"
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  name                       = var.database_name
  username                   = var.database_user
  password                   = var.database_password
  db_subnet_group_name       = aws_db_subnet_group.default[0].id
  vpc_security_group_ids     = var.aws_security_group_ids
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  skip_final_snapshot        = true
  final_snapshot_identifier  = "Ignore"
  multi_az                   = contains(["prod"], var.commonTags["rEnvironmentName"]) ? true : var.multi_az
  port                       = 9500
  backup_retention_period    = 30
  deletion_protection        = var.deletion_protection
  storage_encrypted          = var.storage_encrypted
  apply_immediately          = contains(["prod"], var.commonTags["rEnvironmentName"]) ? true : var.apply_immediately
  parameter_group_name       = aws_db_parameter_group.default[0].name
  tags = merge(
    var.commonTags,
    {
      Name  = "rds-${lower(var.rds_instance_identifier)}",
      uRole = "RdsInstance"
    }
  )
}

// TODO: setup database replication

resource "aws_db_parameter_group" "default" {
  count       = var.database_active
  name        = "${var.rds_instance_identifier}-param-group"
  description = "Parameter group for ${var.parameter_group_family}"
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = local.parameters
    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

locals {
  tf_apply_flags = {
    cloudwatch_alarm = contains(["prod"], var.commonTags["rEnvironmentName"]) ? "true" : "false"
  }
  cw_alarm_defs = local.tf_apply_flags["cloudwatch_alarm"] != "true" ? {} : {
    free_storage_alarm = {
      alarm_name_suffix = "${var.database_name}_rds_storage_alert"
      alarm_description = "${var.database_name}: Storage Reaching Capacity"

      comparison_operator = "LessThanThreshold"
      threshold           = var.storage_alert_threshold * 1024 * 1024 * 1024 #i.e. scale up from bytes to GBs
      evaluation_periods  = "2"
      metric_name         = "FreeStorageSpace"
      period              = "120"
      statistic           = "Average"
      datapoints_to_alarm = "1"
      treat_missing_data  = "notBreaching"
      namespace           = "AWS/RDS"

      dimensions = {
        DBInstanceIdentifier = var.rds_instance_identifier
      }
      actions_enabled = true
      alarm_actions   = [var.sns_topics["${var.commonTags["rEnvironmentName"]}-rds-monitoring"]]
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "objs" {
  for_each = local.cw_alarm_defs

  alarm_name = format("%s-%s-%s",
    var.commonTags["rEnvironmentName"],
    var.database_name,
    each.value.alarm_name_suffix
  )
  alarm_description   = each.value["alarm_description"]
  namespace           = each.value["namespace"]
  dimensions          = each.value["dimensions"]
  metric_name         = each.value["metric_name"]
  statistic           = each.value["statistic"]
  comparison_operator = each.value["comparison_operator"]
  threshold           = each.value["threshold"]
  period              = each.value["period"]
  evaluation_periods  = each.value["evaluation_periods"]
  actions_enabled     = each.value["actions_enabled"]
  alarm_actions       = each.value["alarm_actions"]
  tags                = var.commonTags
}
