# Local variables
locals {
  envName = lower(var.commonTags["rEnvironmentName"])
  instance_parameters = concat([
    {
      apply_method = "immediate"
      name         = "slow_query_log"
      value        = "1"
    },
    {
      apply_method = "immediate"
      name         = "long_query_time"
      value        = "5" #seconds
    },
    {
      apply_method = "immediate"
      name         = "log_queries_not_using_indexes"
      value        = "0"
    },
    {
      apply_method = "immediate"
      name         = "log_slow_admin_statements"
      value        = "1"
    },
    {
      apply_method = "immediate"
      name         = "wait_timeout"
      value        = "1800" #30mins
    },
    {
      apply_method = "immediate"
      name         = "interactive_timeout"
      value        = "10800" #3hours
    },
    {
      apply_method = "immediate"
      name         = "max_connections"
      value        = "16000"
    },
    {
      apply_method = "pending-reboot"
      name         = "log_output"
      value        = "FILE"
    }
  ], var.instance_xtra_parameters)
  cluster_parameters = concat([
    {
      apply_method = "pending-reboot"
      name         = "character_set_client"
      value        = "utf8"
    },
    {
      apply_method = "pending-reboot"
      name         = "innodb_file_per_table"
      value        = "1"
    },
    {
      apply_method = "pending-reboot"
      name         = "binlog_format" #needed for Database migration service
      value        = "ROW"
    },
    {
      apply_method = "pending-reboot"
      name         = "performance_schema"
      value        = "1"
    }
  ], var.cluster_xtra_parameters)

}


resource "aws_db_subnet_group" "default" {
  name        = "${var.cluster_identifier}-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = var.aws_subnet_ids
}


#rds cluster
resource "aws_rds_cluster" "primary" {
  engine                          = "aurora-mysql"
  engine_version                  = var.engine_version
  cluster_identifier              = var.cluster_identifier
  master_username                 = var.database_user
  master_password                 = var.database_password
  database_name                   = var.database_name
  db_subnet_group_name            = aws_db_subnet_group.default.id
  vpc_security_group_ids          = var.aws_security_group_ids
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group_name.name
  skip_final_snapshot             = true
  final_snapshot_identifier       = "Ignore"
  port                            = 9500
  backup_retention_period         = 30
  deletion_protection             = var.deletion_protection
  storage_encrypted               = var.storage_encrypted
  apply_immediately               = var.apply_immediately
  backtrack_window                = var.backtrack_window
  tags = merge(
    var.commonTags,
    {
      Name  = "rds-${lower(var.cluster_identifier)}",
      uRole = "RdsInstance"
    }
  )
  preferred_backup_window      = var.commonTags.oEnvironment == "ci" ? "00:29-00:59" : null
  preferred_maintenance_window = var.commonTags.oEnvironment == "ci" ? "Sun:01:00-Sun:01:30" : null

}

#rds db instance
resource "aws_rds_cluster_instance" "primary" {
  count                                 = var.az_replicas
  engine                                = "aurora-mysql"
  engine_version                        = var.engine_version
  identifier                            = "${var.cluster_instance_identifier}-${count.index}"
  cluster_identifier                    = aws_rds_cluster.primary.id
  instance_class                        = var.instance_class
  db_subnet_group_name                  = aws_db_subnet_group.default.id
  db_parameter_group_name               = aws_db_parameter_group.instance_parameter_group_name.name
  preferred_maintenance_window          = var.commonTags.oEnvironment == "ci" ? "Sun:01:00-Sun:01:30" : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.monitoring_interval
}

#cluster parameter group
resource "aws_rds_cluster_parameter_group" "cluster_parameter_group_name" {
  name        = "${var.cluster_instance_identifier}-clus-param-group"
  description = "Parameter group for ${var.parameter_group_family}"
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = local.cluster_parameters
    content {
      apply_method = parameter.value.apply_method
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
}

#instance parameter group
resource "aws_db_parameter_group" "instance_parameter_group_name" {
  name        = "${var.cluster_instance_identifier}-inst-param-group"
  description = "Parameter group for ${var.parameter_group_family}"
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = local.instance_parameters
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
    Free_Local_Storage = {
      alarm_name_suffix = "Free_local_storage_alert"
      alarm_description = "Free local storage Capacity"

      comparison_operator = "LessThanOrEqualToThreshold"
      threshold           = 100 * 1024 * 1024 #i.e. scale up from bytes to MBs (100MB)
      evaluation_periods  = "2"
      metric_name         = "FreeLocalStorage"
      period              = "120"
      statistic           = "Average"
      datapoints_to_alarm = "1"
      treat_missing_data  = "notBreaching"
      namespace           = "AWS/RDS"

      dimensions = {
        DBClusterIdentifier = var.cluster_identifier
        Role                = "WRITER"
      }
      actions_enabled = true
      alarm_actions   = [var.sns_topics["${var.commonTags["rEnvironmentName"]}-Aurora-monitoring"]]
    },
    CPUUtilization = {
      alarm_name_suffix = "CPU_Utilization_alert"
      alarm_description = "CPU Utilization excessive over period "

      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 95 #95%
      evaluation_periods  = "2"
      metric_name         = "CPUUtilization"
      period              = "120"
      statistic           = "Maximum"
      datapoints_to_alarm = "1"
      treat_missing_data  = "notBreaching"
      namespace           = "AWS/RDS"

      dimensions = {
        DBClusterIdentifier = var.cluster_identifier
        Role                = "WRITER"
      }
      actions_enabled = true
      alarm_actions   = [var.sns_topics["${var.commonTags["rEnvironmentName"]}-Aurora-monitoring"]]

    },
    AuroraReplicaLag = {
      alarm_name_suffix = "Aurora_Replica_Lag_alert"
      alarm_description = "Aurora Replica Lag excessive over period "

      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 60000 #1min
      evaluation_periods  = "2"
      metric_name         = "AuroraReplicaLag"
      period              = "120"
      statistic           = "Maximum"
      datapoints_to_alarm = "1"
      treat_missing_data  = "notBreaching"
      namespace           = "AWS/RDS"

      dimensions = {
        DBClusterIdentifier = var.cluster_identifier
        Role                = "READER"
      }
      actions_enabled = true
      alarm_actions   = [var.sns_topics["${var.commonTags["rEnvironmentName"]}-Aurora-monitoring"]]

    },
    Deadlocks = {
      alarm_name_suffix = "Deadlocks_alert"
      alarm_description = "Deadlocks excessive over period "

      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 3 #count per second
      evaluation_periods  = "2"
      metric_name         = "Deadlocks"
      period              = "60"
      statistic           = "Maximum"
      datapoints_to_alarm = "1"
      treat_missing_data  = "notBreaching"
      namespace           = "AWS/RDS"

      dimensions = {
        DBClusterIdentifier = var.cluster_identifier
        Role                = "WRITER"
      }
      actions_enabled = true
      alarm_actions   = [var.sns_topics["${var.commonTags["rEnvironmentName"]}-Aurora-monitoring"]]

    }

  }
}

resource "aws_cloudwatch_metric_alarm" "objs" {
  for_each = local.cw_alarm_defs

  alarm_name = format("%s-%s",
    var.cluster_identifier,
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
