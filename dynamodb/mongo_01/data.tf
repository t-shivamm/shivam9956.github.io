##########################################################################
##
data "aws_ssm_parameter" "ssmParamName_sitecoreMongoMasterUsername" {
  name            = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_sitecoremongo}/MasterUsername" # = "in/secure/role_credentials/sitecoreMongo/MasterUsername
  with_decryption = true
}
data "aws_ssm_parameter" "ssmParamName_sitecoreMongoMasterPassword" {
  name            = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_sitecoremongo}/MasterPassword" # = "in/secure/role_credentials/sitecoreMongo/MasterPassword
  with_decryption = true
}
##
##########################################################################