locals {
  parameters = concat([
    {
      name  = "cost threshold for parallelism"
      value = "50"
    },
    {
      name  = "remote admin connections"
      value = "1"
    }
  ], var.xtra_parameters)
}

########################################################################
### Enable RDS Instance in subnet(s) if defined as active, overwise skip

resource "aws_db_subnet_group" "default" {
  count      = var.database_active == "true" ? 1 : 0
  name       = "${var.mysql_instance_identifier}-subnet-group"
  subnet_ids = var.aws_subnet_ids
}

resource "aws_db_instance" "default" {
  count                      = var.database_active == "true" ? 1 : 0
  identifier                 = var.mysql_instance_identifier
  engine                     = var.engine
  engine_version             = var.engine_version
  username                   = var.database_user
  password                   = var.database_password
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.default[0].id
  port                       = var.port
  vpc_security_group_ids     = var.aws_security_group_ids
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = var.max_allocated_storage
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  maintenance_window         = "Mon:00:00-Mon:03:00"
  backup_window              = "03:00-06:00"
  backup_retention_period    = var.backup_retention_period
  final_snapshot_identifier  = var.mysql_instance_identifier
  parameter_group_name       = aws_db_parameter_group.default[0].name
  timezone                   = "UTC"
  multi_az                   = var.multi_az
  publicly_accessible        = false
  storage_encrypted          = var.storage_encrypted
  kms_key_id                 = ""
  license_model              = var.license_model
  deletion_protection        = var.deletion_protection
  apply_immediately          = false
}

###### Instance definition
########################################################################

resource "aws_db_parameter_group" "default" {
  count       = var.database_active
  name        = "${var.rds_instance_identifier}-param-group"
  description = "Parameter group for ${var.parameter_group_family}"
  family      = var.parameter_group_family

  dynamic "parameter" {
    for_each = local.parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

}
