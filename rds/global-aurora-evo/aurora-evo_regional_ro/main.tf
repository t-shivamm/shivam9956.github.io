locals {
  regional_deployment = var.regional_ro_replica == "false" ? 0 : 1
}

resource "aws_db_subnet_group" "extra_region" {
  count       = local.regional_deployment
  name        = "${var.cluster_identifier}-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = var.aws_subnet_ids
}

resource "aws_rds_cluster" "secondary" {
  count                     = local.regional_deployment
  engine                    = var.global_cluster_engine
  engine_version            = var.global_cluster_engine_version
  cluster_identifier        = var.cluster_identifier
  global_cluster_identifier = var.global_cluster_id
  db_subnet_group_name      = aws_db_subnet_group.extra_region[0].id
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

resource "aws_rds_cluster_instance" "secondary" {
  count                = local.regional_deployment
  engine               = var.global_cluster_engine
  engine_version       = var.global_cluster_engine_version
  identifier           = var.cluster_instance_identifier
  cluster_identifier   = aws_rds_cluster.secondary[0].id
  instance_class       = var.instance_class
  db_subnet_group_name = aws_db_subnet_group.extra_region[0].id

}
