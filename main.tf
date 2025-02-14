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
