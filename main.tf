
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
=======
# Local variables
locals {
  envName      = lower(var.commonTags["rEnvironmentName"])
  subnetIdList = var.tiersbntGrpListMap[var.asgRoleMap["asgSubnetGroup"]]

  #Spots & Dynamic Scaling Initialization block
  spotsEnable = length(try(var.asgRoleMap["asgMixedInstanceMap"], {})) > 0 ? "true" : "false"

  # Launch template block device mappings
  block_device_mappings = merge(
    # We always want the root definition
    {
      root = {
        device_name = ( # hard code the root device name
          var.isWindows == "true"
          ? lookup(var.asgLcMap, "lcRootDeviceName", "/dev/sda1")
          : lookup(var.asgLcMap, "lcRootDeviceName", "/dev/xvda")
        )
        ebs = {
          volume_size           = lookup(var.asgLcMap, "lcRootDeviceSizeInGb", null)
          volume_type           = lookup(var.asgLcMap, "lcRootDeviceType", "gp3") # default gp3
          iops                  = lookup(var.asgLcMap, "lcRootDeviceIops", null)
          throughput            = lookup(var.asgLcMap, "lcRootDeviceThroughput", null)
          kms_key_id            = lookup(var.asgLcMap, "lcRootDeviceKmsKeyId", null)
          snapshot_id           = null # Not required for the root device, as it's defined by AMI
          delete_on_termination = true
          encrypted             = true
        }
      }
    },
    # Additional block device is optional
    lookup(var.asgLcMap, "lcBlockDeviceSizeInGb", "0") == "0" ? {} : {
      block = {
        device_name = lookup(var.asgLcMap, "lcBlockDeviceName", null)
        ebs = {
          volume_size           = lookup(var.asgLcMap, "lcBlockDeviceSizeInGb", null)
          volume_type           = lookup(var.asgLcMap, "lcBlockDeviceType", null)
          iops                  = lookup(var.asgLcMap, "lcBlockDeviceIops", null)
          throughput            = lookup(var.asgLcMap, "lcBlockDeviceThroughput", null)
          kms_key_id            = lookup(var.asgLcMap, "lcBlockDeviceKmsKeyId", null)
          snapshot_id           = lookup(var.asgLcMap, "lcBlockDeviceSnapshotId", null)
          delete_on_termination = true
          encrypted             = true
        }
      }
    }
  )


}


################################################################################
### Autoscaling Core

##Mixed Instances ASG's

resource "aws_autoscaling_group" "asg" {
  name                = "${local.envName}-asg-${lower(var.asgRoleMap["asgRole"])}"
  vpc_zone_identifier = local.subnetIdList


  # For those who don't appreciate value of spot instances for stateless applications
  # And just like plain old ASG setup
  dynamic "launch_template" {
    for_each = toset((local.spotsEnable == "false") ? ["enabled"] : [])
    content {
      id = aws_launch_template.lcNoDataDisk.id # keeping the name for legacy support
    }
  }
  # For those who remains on top of their game and update their estate to stable bleeding edge features
  # Leverage power of mixed instance for spots
  dynamic "mixed_instances_policy" {
    for_each = toset((local.spotsEnable == "true") ? ["enabled"] : [])

    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.lcNoDataDisk.id # keeping the name for legacy support
        }
        dynamic "override" {
          for_each = toset(var.asgRoleMap["asgMixedInstanceMap"].mixedInstanceList)
          content {
            instance_type = override.value
          }
        }
      }
      instances_distribution {
        on_demand_base_capacity                  = var.asgRoleMap["asgMixedInstanceMap"].onDemandBaseCap
        on_demand_percentage_above_base_capacity = var.asgRoleMap["asgMixedInstanceMap"].onDemandPercentage
        spot_allocation_strategy                 = try(var.asgRoleMap["spotAllocationStrategy"], "capacity-optimized")
        on_demand_allocation_strategy            = "prioritized"
      }
    }
  }

  max_size                  = var.asgRoleMap["asgMaxSize"]
  min_size                  = var.asgRoleMap["asgMinSize"]
  desired_capacity_type     = lookup(var.asgRoleMap, "asgDesiredCapacityType", "units")
  health_check_grace_period = var.asgRoleMap["asgGracePeriodInSecs"]
  health_check_type         = var.HealthCheckType
  force_delete              = var.asgRoleMap["asgForceDelete"]
  default_cooldown          = var.asgRoleMap["asgDefaultCooldownInSecs"]
  termination_policies      = ["OldestInstance"]
  suspended_processes       = compact(split(",", var.asgRoleMap["asgDisableAutoTerminate"] == "true" ? "Terminate,ReplaceUnhealthy" : ""))

  dynamic "tag" {
    for_each = var.commonTags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.envName}-asg-${lower(var.asgRoleMap["asgRole"])}"
    propagate_at_launch = true
  }

  tag {
    key                 = "uRole"
    value               = "AsgInstance"
    propagate_at_launch = true
  }

  tag {
    key                 = "oPowerOffCOB"
    value               = "NoBecauseAsg"
    propagate_at_launch = true
  }

  tag {
    key                 = "oSpotInstances"
    value               = "true"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  lifecycle {
    ignore_changes        = [load_balancers, target_group_arns]
    create_before_destroy = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTotalCapacity"
  ]
}


### Autoscaling Core
################################################################################

################################################################################
### Launch Templates

resource "aws_launch_template" "lcNoDataDisk" { # keeping the name for legacy support
  name_prefix            = "${local.envName}-launchTemplate-${var.asgRoleMap["asgRole"]}-noDisk_"
  image_id               = var.lcAmiId
  key_name               = lookup(var.asgLcMap, "lcKeyName", "")
  instance_type          = var.asgLcMap["lcInstanceType"]
  ebs_optimized          = var.asgLcMap["lcEnableEbsOptimised"]
  update_default_version = true
  iam_instance_profile {
    name = var.lcIamInstanceProfile
  }
  vpc_security_group_ids = var.sgIdList

  user_data = base64encode(data.template_file.userdata_s3.rendered)

  # Block devices - root and additional
  dynamic "block_device_mappings" {
    for_each = local.block_device_mappings

    content {
      device_name = block_device_mappings.value["device_name"]
      ebs {
        volume_size           = block_device_mappings.value["ebs"].volume_size
        volume_type           = block_device_mappings.value["ebs"].volume_type
        iops                  = block_device_mappings.value["ebs"].iops
        throughput            = block_device_mappings.value["ebs"].throughput
        kms_key_id            = block_device_mappings.value["ebs"].kms_key_id
        snapshot_id           = block_device_mappings.value["ebs"].snapshot_id
        delete_on_termination = block_device_mappings.value["ebs"].delete_on_termination
        encrypted             = true
      }
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []
    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }
}

data "template_file" "userdata_s3" {
  template = file("${path.cwd}/../../../../resources/scripts/userdata-v2/${var.asgRoleMap.userdataLocalFilename}")
  vars = {
    paramsHashtableArray = var.asgRoleMap.userdataParamsArray
    script_s3_bucket     = var.userdata_s3.script_s3_bucket
    script_s3_key        = var.userdata_s3.script_s3_key
  }
}

### Launch Templates
################################################################################


################################################################################
### Autoscaling Scale Out/In On Schedule

# Scale Down
resource "aws_autoscaling_schedule" "ScaleDown" {
  count                  = var.aspDevEnvironment == "true" && var.enableScaleDown == "true" ? 1 : 0
  scheduled_action_name  = "Scale-Down-${lower(var.asgRoleMap["asgRole"])}"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = lookup(var.asgRoleMap, "asgScaleDownCron", "not_found") == "not_found" ? "00 22 * * 1-5" : var.asgRoleMap["asgScaleDownCron"]
  autoscaling_group_name = "${local.envName}-asg-${lower(var.asgRoleMap["asgRole"])}"

  depends_on = [
    aws_autoscaling_group.asg,
  ]
}

# Scale Up
resource "aws_autoscaling_schedule" "ScaleUp" {
  count                  = var.aspDevEnvironment == "true" && var.enableScaleUp == "true" ? 1 : 0
  scheduled_action_name  = "Scale-Up-${lower(var.asgRoleMap["asgRole"])}"
  min_size               = var.asgRoleMap["asgMaxSize"]
  max_size               = var.asgRoleMap["asgMaxSize"]
  desired_capacity       = var.asgRoleMap["asgMaxSize"]
  recurrence             = lookup(var.asgRoleMap, "asgScaleUpCron", "not_found") == "not_found" ? "00 04 * * 1-5" : var.asgRoleMap["asgScaleUpCron"]
  autoscaling_group_name = "${local.envName}-asg-${lower(var.asgRoleMap["asgRole"])}"

  depends_on = [
    aws_autoscaling_group.asg,
  ]


}

### Autoscaling Scale Out/In On Schedule
################################################################################
