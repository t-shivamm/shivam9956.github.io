module "mongo_01" {
  source          = "../../../../neomodules_0.12/docdb/mongodb"
  database_active = "true"

  aws_subnet_ids = data.terraform_remote_state.core_0.outputs.sto-listMap-sbntGrp-data["dat01"]

  aws_security_group_ids = [
    data.terraform_remote_state.core_1.outputs.sto-stringMap-securitygroups-sgId["db_SiteCoreMongo01"],
  ]

  docdb_instance_identifier      = "${local.env_name}-mongo-01"
  database_name                  = "te-sitecore-mongodb"
  database_user                  = data.aws_ssm_parameter.ssmParamName_sitecoreMongoMasterUsername.value
  database_password              = data.aws_ssm_parameter.ssmParamName_sitecoreMongoMasterPassword.value
  tls                            = "disabled"
  port                           = 27017
  deletion_protection            = true
  cluster_parameter_group_family = "docdb3.6"

  commonTags = var.commonTags
}
