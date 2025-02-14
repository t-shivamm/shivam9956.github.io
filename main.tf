##PPBO Db Creds from SSM ####
data "aws_ssm_parameter" "ppbo_db_username" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_ppbo}/db.username"
}
data "aws_ssm_parameter" "ppbo_db_password" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_ppbo}/db.password"
}

##BCGW Db Creds from SSM ####
data "aws_ssm_parameter" "bcgw_db_username" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_bcgw}/db.username"
}
data "aws_ssm_parameter" "bcgw_db_password" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_bcgw}/db.password"
}

##LGW Db Creds from SSM ####
data "aws_ssm_parameter" "lgw_db_username" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_lgw}/db.username"
}
data "aws_ssm_parameter" "lgw_db_password" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_lgw}/db.password"
}

##SUP Db Creds from SSM ####
data "aws_ssm_parameter" "sup_db_username" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_sup}/db.username"
}
data "aws_ssm_parameter" "sup_db_password" {
  name = "${local.ssmpSecureLocs.d-roleCredentials}/${local.db_role_sup}/db.password"
}

locals {
  # Define these autoscaling role references from the asg.tfvars file
  asgLcMap         = var.asgLaunchConfigs.domain-service
  asgCloudwatchMap = var.asgCloudwatch.default

  mixedInstanceMap = var.mixedInstancePlansMap.basic.linux
  asgScalingMap = {
    targettracking = {
      requestcount = { ##Only Applicable for Services behind ALB
        enabled       = "false"
        targetvalue   = 60
        resourcelabel = " " # this needs to populated when enabling request count
      }
      cpuutil = {
        enabled     = "false"
        targetvalue = 70
      }
      netin = {
        enabled     = "false"
        targetvalue = 60
      }
      simplescaling = {}
    }
  }

  appd_machine_agent_s3_rpmname = "appdynamics-machine-agent-22.5.0.3361.x86_64.rpm"

  ### Autoscaling Group
  role_name     = "accesskey"
  appd_app_name = "Access Key"
  asgRoleMap = {
    asgRole                  = local.role_name
    asgTier                  = "private"
    asgSubnetGroup           = "prv03"
    asgMinSize               = "1"
    asgMaxSize               = "1"
    asgDisableAutoTerminate  = "false"
    asgScaleDownCron         = "59 23 * * 5"
    asgScaleUpCron           = "00 05 * * 1"
    asgGracePeriodInSecs     = "720"
    asgForceDelete           = "false"
    asgDefaultCooldownInSecs = "600"
    asgSpotsEnable           = "true"
    spotAllocationStrategy   = "price-capacity-optimized"
    asgMixedInstanceMap      = local.mixedInstanceMap
    aspEnabled               = "false"
    cwAlarmActionsEnable     = "false"
    userdataLocalFilename    = "centos_userdata.sh"
    userdataS3ScriptAlias    = "centos_deploy_domain-service_withappd-v3_imdsv2"
    userdataParamsArray      = replace(replace(local.userdataParamsArrayFriendly, "/\r\n/", "\n"), "/\n/", " ")
  }
  userdataParamsArrayFriendly = <<-EOT
    [s3bucket]=${var.roleVariables.deploymentBucketName}
    [s3keynameprefix]='/${local.role_name}/'
    [port]=${local.localAppPort}
    [env]=${local.env_name}
    [application]='${local.role_name}.jar'
    [microservicesnlb]=${data.terraform_remote_state.core_2.outputs.sto-stringMapMap-lb-attributes[local.nlbName].dns_name}
    [datasourceurl]=jdbc:mysql://${data.terraform_remote_state.db_stnd-au-mysql2.outputs.stnd-au-mysql2-endpoint}:9500/${local.db_naming_map.rdsDbName}
    [datasourcename_ssmpname]=${local.ssmpSecureLocs.d-roleCredentials}/${local.db_naming_map.rdsDbName}/au_db.username
    [datasourcepassword_ssmpname]=${local.ssmpSecureLocs.d-roleCredentials}/${local.db_naming_map.rdsDbName}/au_db.password
    [nlb_ips]=${join(",", data.terraform_remote_state.core_2.outputs.sto-listMap-nlbIpLists.nlbPrivateDomain)}
    [ssm_region]=${var.tfAwsRegion}
    [jvmheapsize]=${local.asgLcMap["lcJVMHeapSize"]}
    [microservicename]=${local.role_name}
    [withappd]='TRUE'
    [cloudwatch_agent]='TRUE'
    [appd_sim_enabled]='true'
    [cloudwatch_agent_ssm_config_name]='ssm:/${local.env_name}/out/insecure/role_attributes/${local.env_name}/cwagent/default'
    [service_specific_args]='
      -Dcollinson.monitoring.logHttp=false
      -Dconsumer.remote.http.enabled=true
      -Dconsumer.remote.http.url=https://consumer.${local.hostnameSuffix}/consumer-service/
      -Dlog4j2.formatMsgNoLookups=true
      -Dmanagement.endpoints.web.exposure.include=refresh,info,health
      -Dorg.jboss.logging.provider=slf4j
      -Dproduct.remote.http.enabled=true
      -Dproduct.remote.http.url=https://product.${local.hostnameSuffix}/product-service/
      -Dserver.port.http=${local.localAppHTTPPort}
      -Dspring.bankcardgateway.datasource.jdbcUrl=${local.db_config_bcgw.database_connection_string}
      -Dspring.bankcardgateway.datasource.username=${local.db_config_bcgw.database_username}
      -Dspring.loungegateway.datasource.jdbcUrl=${local.db_config_lgw.database_connection_string}
      -Dspring.loungegateway.datasource.username=${local.db_config_lgw.database_username}
      -Dspring.ppass.datasource.jdbcUrl=${local.db_config_ppbo.database_connection_string}
      -Dspring.ppass.datasource.username=${local.db_config_ppbo.database_username}
      -Dspring.sup.datasource.jdbcUrl=${local.db_config_sup.database_connection_string}
      -Dspring.sup.datasource.username=${local.db_config_sup.database_username}
      -Dsubscription.port=${var.services_config.domain_services.ports.subscription}
      -Dsubscription.remote.http.enabled=true
      -Dsubscription.remote.http.url=https://subscription.${local.hostnameSuffix}/subscription/
      -Dsup.batch.id=1060
    '
    [service_specific_args_ssm]='${join(" ", [for k, v in local.service_specific_args_ssm : "${v.arg}=${v.ssmp_name}"])}'
    [appd_machine_agent_s3_rpmname]='${local.appd_machine_agent_s3_rpmname}'
    [appd_asa_s3_zipname]='${var.services_config.common.appd_config.appd_asa_s3_zipname}'
    [appd_asa_jar_path]='${var.services_config.common.appd_config.appd_asa_jar_path}'
    [appd_ctrl_hostname]='${var.services_config.common.appd_config.appd_ctrl_hostname}'
    [appd_agent_accountname_ssmpname]='${local.ssmpSecureLocs.d-roleCredentials}${var.services_config.common.appd_config.appd_agent_accountname_ssmpnamesuffix}'
    [appd_agent_accountaccesskey_ssmpname]='${local.ssmpSecureLocs.d-roleCredentials}${var.services_config.common.appd_config.appd_agent_accountaccesskey_ssmpnamesuffix}'
    [appd_agent_applicationname]='${var.services_config.common.appd_config.appd_agent_applicationname}'
    [appd_agent_tiername]='${local.appd_app_name}'
    [appd_account_name]='${var.services_config.common.appd_config.appd_account_name}'
  EOT

  service_specific_args_ssm = { # Used in roles.tf to give read rights to these parameters
    ppass_password = { arg = "-Dspring.ppass.datasource.password", ssmp_name = data.aws_ssm_parameter.ppbo_db_password.name }
    bcgw_password  = { arg = "-Dspring.bankcardgateway.datasource.password", ssmp_name = data.aws_ssm_parameter.bcgw_db_password.name }
    lgw_password   = { arg = "-Dspring.loungegateway.datasource.password", ssmp_name = data.aws_ssm_parameter.lgw_db_password.name }
    sup_password   = { arg = "-Dspring.sup.datasource.password", ssmp_name = data.aws_ssm_parameter.sup_db_password.name }
  }

  ### Database
  ## PPBO database repointing
  db_role_ppbo          = "ppbo"
  db_host_ppbo          = "db01"
  db_host_ppbo_failover = "db01"
  db_name_ppbo          = "PPassUAT"
  db_config_ppbo = {
    # database_connection_string  = "'jdbc:sqlserver://${data.aws_ssm_parameter.dbhostname.value};databaseName=${local.db_name};failoverPartner=${local.db_role_name_failover}'"
    database_connection_string = "jdbc:sqlserver://SQL-LIST-INTE;MultiSubnetFailover=True;databaseName=${local.db_name_ppbo}"
    database_username          = data.aws_ssm_parameter.ppbo_db_username.value
    database_password          = data.aws_ssm_parameter.ppbo_db_password.value
  }

  ## BCGW database repointing
  db_role_bcgw          = "bcgw"
  db_host_bcgw          = "db01"
  db_host_bcgw_failover = "db01"
  db_name_bcgw          = "BankCardGateway_UAT"
  db_config_bcgw = {
    # database_connection_string  = "'jdbc:sqlserver://${data.aws_ssm_parameter.dbhostname.value};databaseName=${local.db_name};failoverPartner=${local.db_role_name_failover}'"
    database_connection_string = "jdbc:sqlserver://10.215.196.112;databaseName=${local.db_name_bcgw};"
    database_username          = data.aws_ssm_parameter.bcgw_db_username.value
    database_password          = data.aws_ssm_parameter.bcgw_db_password.value
  }

  ## LGW database repointing
  db_role_lgw          = "loungegateway_evo"
  db_host_lgw          = "db01"
  db_host_lgw_failover = "db01"
  db_name_lgw          = "LoungeGateway_UAT"
  db_config_lgw = {
    # database_connection_string  = "'jdbc:sqlserver://${data.aws_ssm_parameter.dbhostname.value};databaseName=${local.db_name};failoverPartner=${local.db_role_name_failover}'"
    database_connection_string = "jdbc:sqlserver://SQL-LIST-INTE;MultiSubnetFailover=True;databaseName=${local.db_name_lgw}"
    database_username          = data.aws_ssm_parameter.lgw_db_username.value
    database_password          = data.aws_ssm_parameter.lgw_db_password.value
  }

  ## SUP database repointing
  db_role_sup          = "singleusepass_evo"
  db_host_sup          = "db01"
  db_host_sup_failover = "db01"
  db_name_sup          = "SUP"
  db_config_sup = {
    database_connection_string = "jdbc:sqlserver://10.215.196.112;databaseName=${local.db_name_sup};"
    database_username          = data.aws_ssm_parameter.sup_db_username.value
    database_password          = data.aws_ssm_parameter.sup_db_password.value
  }

  # The name definitions are in global.tfvars
  db_naming_map = zipmap(
    split("|", var.services_config.domain_services.rds.zipmapHeaders),
    split("|", (replace(var.services_config.domain_services.rds[local.role_name], "<env_name>", local.env_name)))
  )

  # NLB routing config
  localAppPort                      = "8080"
  localAppHTTPPort                  = "8081"
  nlbName                           = "nlbPrivateDomain"
  nlbPort                           = lookup(var.services_config.domain_services.ports, local.role_name)
  domain_services_nlbName           = "nlbPrivateDomain"
  domain_services_albName           = "albPrivateDomain"
  service_endpoint_alb_listener_arn = data.terraform_remote_state.core_2.outputs.sto-string-albPrivateDomain-albListenerHttpsArn

  ### ALB Routing Config
  #? The null and {} attributes will be made optional at the module in the future
  # see - https://www.terraform.io/docs/language/functions/defaults.html

  r53HostedZoneId = data.terraform_remote_state.core_0.outputs.sto-stringMap-vpcRouting-r53PrivateZoneInfo["id"]
  hostnameSuffix  = data.terraform_remote_state.core_0.outputs.sto-stringMap-vpcRouting-r53PrivateZoneInfo["name"]

  alb_listener_rule_conditions = {
    default = {
      path_pattern = null
      host_header = {
        values = ["${local.role_name}.${local.hostnameSuffix}"]
      }
      http_header_defs    = {}
      http_request_method = null
      query_string_defs   = {}
      source_ip           = null
    }
  }
  r53ARecordNames = [
    local.role_name
  ]
  tgAttrMap = {
    port                 = local.localAppHTTPPort
    protocol             = "HTTP"
    deregistration_delay = "60"
    proxy_protocol_v2    = "false"
    interval             = "10"
    healthy_threshold    = "3"
    unhealthy_threshold  = "3"
  }
  tgHealthCheckMap = {
    enabled             = "true"
    path                = "/${local.role_name}/actuator/health"
    port                = local.localAppHTTPPort
    protocol            = "HTTP"
    interval            = "10"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    matcher             = "200"
  }
  tgStickinessMap = {
    enabled = "false"
  }

  # Construct the maps that contain the locations of the SSMP locations
  ssmpSecureLocs = zipmap(
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpSecureLocs.zipmapKeys,
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpSecureLocs.zipmapValues
  )
  ssmpConfLocs = zipmap(
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpConfLocs.zipmapKeys,
    data.terraform_remote_state.core_0.outputs.sto-listMap-ssmpConfLocs.zipmapValues
  )

  env_name = var.commonTags.oEnvironment
}

################################################################################
### cloudwatch subscription filter

resource "aws_cloudwatch_log_subscription_filter" "logging" {
  name            = "${var.commonTags.oEnvironment}-${local.role_name}-log-aggregate"
  log_group_name  = "/ec2/${var.commonTags.oEnvironment}-${local.role_name}"
  filter_pattern  = ""
  destination_arn = data.terraform_remote_state.core_4_log-aggregate.outputs.lambda_attr.arn[0]
}

### cloudwatch subscription filter
################################################################################

################################################################################
### Autoscaling Group

# AMI data provider
data "aws_ami" "ami" {
  most_recent      = true
  executable_users = ["self"]
  name_regex       = "^awslinux-poc_.*$"
  owners           = ["864800382645"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "asg" {
  source = "../../../../neomodules_1.x/autoscaling-v3"

  #####################
  # Disable ASG Out of Hours
  aspDevEnvironment = false
  # Disable ASG Out of Hours
  #####################

  # Edit these role-specific references
  isWindows            = data.aws_ami.ami.platform == "Windows" ? "true" : "false"
  tiersbntGrpListMap   = data.terraform_remote_state.core_0.outputs.sto-listMap-subnet-groups[local.asgRoleMap.asgTier]
  topicArnList         = [data.terraform_remote_state.core_3.outputs.sto-string-temp-userUpdatesArn]
  lcAmiId              = "resolve:ssm:/inte/ami/linux/amazon"
  lcIamInstanceProfile = aws_iam_instance_profile.instance_profile.name

  commonTags       = var.commonTags
  asgRoleMap       = local.asgRoleMap
  asgLcMap         = local.asgLcMap
  asgScalingMap    = local.asgScalingMap
  asgCloudwatchMap = local.asgCloudwatchMap
  sgIdList         = [lookup(data.terraform_remote_state.core_1.outputs.sto-stringMap-securitygroups-sgId, local.asgRoleMap["asgRole"])]
  userdata_s3 = {
    script_s3_bucket = data.terraform_remote_state.core_5_userdata_s3.outputs.s3_userdata_scripts_attributes_imdsv2[local.asgRoleMap.userdataS3ScriptAlias].bucket
    script_s3_key    = data.terraform_remote_state.core_5_userdata_s3.outputs.s3_userdata_scripts_attributes_imdsv2[local.asgRoleMap.userdataS3ScriptAlias].key
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

### Autoscaling Group
################################################################################

################################################################################
### NLB Request Routing

# module "request-routing" {
#   source = "../../../../neomodules_1.x/nlb-routing"
#   nlbArn     = data.terraform_remote_state.core_2.outputs.sto-stringMapMap-lb-attributes[local.nlbName].lbArn
#   tgAlias    = "${local.role_name}-${local.asgRoleMap.asgTier}"
#   vpcId      = data.terraform_remote_state.core_0.outputs.sto-string-vpcRouting-vpcId
#   commonTags = var.commonTags

#   tcpListenerList = [local.nlbPort]

#   tgHealthCheckMap = {
#     enabled             = "true"
#     port                = local.localAppPort
#     protocol            = "TCP"
#     interval            = "10"
#     timeout             = "5"
#     healthy_threshold   = "3"
#     unhealthy_threshold = "3"
#   }

#   tgAttrMap = {
#     port = local.localAppPort
#   }

#   target = {
#     type = "asg"
#     id   = module.asg.asgId
#   }
# }

### NLB Request Routing
################################################################################

################################################################################
### ALB Request Routing

module "alb-request-routing" {
  source = "../../../../neomodules_1.x/alb-request-routing-v2"

  tgAlias              = "${local.role_name}-${local.asgRoleMap.asgTier}"
  albListenerArn       = local.service_endpoint_alb_listener_arn
  r53HostedZoneId      = local.r53HostedZoneId
  cwAlarmActionsEnable = "false"
  r53ARecordNames      = local.r53ARecordNames

  # The values below here shouldn't need to change
  asgName = module.asg.asgName
  vpcId   = data.terraform_remote_state.core_0.outputs.sto-string-vpcRouting-vpcId

  alb_listener_rule_conditions = local.alb_listener_rule_conditions
  tgAttrMap                    = local.tgAttrMap
  tgHealthCheckMap             = local.tgHealthCheckMap
  tgStickinessMap              = local.tgStickinessMap

  asgCloudwatchMap             = local.asgCloudwatchMap
  cwTgHealthyHostsAlarmActions = [data.terraform_remote_state.core_3.outputs.sto-string-temp-userUpdatesArn]
  commonTags                   = var.commonTags

  target = {
    type = "asg"
    id   = module.asg.asgId
  }
}

### ALB Request Routing
################################################################################

################################################################################
### SSM Parameters

module "ssmp-endpointUrl" {
  source = "../../../../neomodules_1.x/ssm-param"

  tier        = "Standard"
  type        = "String"
  namePrefix  = local.ssmpConfLocs.d-roleAttributes
  name        = "${local.role_name}/endpointUrl"
  value       = "${data.terraform_remote_state.core_2.outputs.sto-stringMapMap-lb-attributes[local.nlbName].dns_name}:${local.nlbPort}"
  overwrite   = "true"
  description = "Endpoint URL for the role: ${local.role_name}"
  commonTags  = var.commonTags
}

module "ssmp-asgMaxSize" {
  source = "../../../../neomodules_1.x/ssm-param"

  tier        = "Standard"
  type        = "String"
  namePrefix  = local.ssmpConfLocs.d-roleAttributes
  name        = "${local.role_name}/asg.max_size"
  value       = module.asg.asgAttributes.max_size
  overwrite   = "true"
  description = "ASG max size for role: ${local.role_name}"
  commonTags  = var.commonTags
}

module "ssmp-asgMinSize" {
  source = "../../../../neomodules_1.x/ssm-param"

  tier        = "Standard"
  type        = "String"
  namePrefix  = local.ssmpConfLocs.d-roleAttributes
  name        = "${local.role_name}/asg.min_size"
  value       = module.asg.asgAttributes.min_size
  overwrite   = "true"
  description = "ASG min size for role: ${local.role_name}"
  commonTags  = var.commonTags
}

### SSM Parameters
################################################################################
