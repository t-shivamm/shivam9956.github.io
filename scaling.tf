################################################################################
### Autoscaling Scale Out/In Policies and CloudWatch Alarms

###Target Tracking Scaling
## 1: Load Balancer network count
resource "aws_autoscaling_policy" "asg-policy-targettracking-elbrequestcount" {
  count                  = try(var.asgScalingMap.targettracking.requestcount.enabled, "false") == "true" ? 1 : 0
  name                   = "ASG-TargetTracking-RequestCount-${lower(var.asgRoleMap["asgRole"])}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = var.asgScalingMap.targettracking.requestcount.resourcelabel
    }

    target_value = try(var.asgScalingMap.targettracking.requestcount.targetvalue, 60)
  }
}

## 2: CPU Utilization
resource "aws_autoscaling_policy" "asg-policy-targettracking-cpuutil" {
  count                  = try(var.asgScalingMap.targettracking.cpuutil.enabled, "false") == "true" ? 1 : 0
  name                   = "ASG-TargetTracking-CPUUtilization-${lower(var.asgRoleMap["asgRole"])}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
      resource_label         = var.aspTGResourceLabel
    }

    target_value = try(var.asgScalingMap.targettracking.cpuutil.targetvalue, 70)
  }
}

## 2: Network In
resource "aws_autoscaling_policy" "asg-policy-targettracking-networkin" {
  count                  = try(var.asgScalingMap.targettracking.netin.enabled, "false") == "true" ? 1 : 0
  name                   = "ASG-TargetTracking-NetworkIn${lower(var.asgRoleMap["asgRole"])}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
      resource_label         = var.aspTGResourceLabel
    }

    target_value = try(var.asgScalingMap.targettracking.netin.targetvalue, 50)
  }
}

###Target Tracking Scaling Ends
###This should phase out as Target Tracking simplifies scaling policies
# Scale Out
# resource "aws_autoscaling_policy" "asg-policy_scale-out" {
#   count                  = var.asgRoleMap["aspCPUEnabled"] == "true" || var.asgRoleMap["aspNetInEnabled"] == "true" ? 1 : 0
#   name                   = "ASG-POLICY-SCALE-OUT-${lower(var.asgRoleMap["asgRole"])}"
#   policy_type            = "SimpleScaling"
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = abs(var.asgScalingMap["aspScaleOutNodesToAdd"])
#   cooldown               = var.asgScalingMap["aspScaleOutCoolDown"]
# }

# resource "aws_cloudwatch_metric_alarm" "cw_cpu-high_alarm" {
#   count               = var.asgRoleMap["aspCPUEnabled"] == "true" ? 1: 0
#   alarm_name          = "${lower(var.commonTags["oEnvironment"])}-asg-${lower(var.asgRoleMap["asgRole"])}-CPU-HIGH"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.asgScalingMap["scaleOutCwCPUAlarmEvalPeriodsCount"]
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = var.asgScalingMap["scaleOutCwCPUAlarmEvalPeriodInSecs"]
#   statistic           = "Average"
#   threshold           = var.asgScalingMap["scaleOutCwCPUAlarmEvalThresholdPercent"]
#   alarm_description   = "Autoscaling CPU% average was over ${var.asgScalingMap["scaleOutCwCPUAlarmEvalThresholdPercent"]}% for ${var.asgScalingMap["scaleOutCwCPUAlarmEvalPeriodsCount"] * var.asgScalingMap["scaleOutCwCPUAlarmEvalPeriodInSecs"]} seconds. Triggering scale OUT action unless we are at ${var.asgRoleMap["asgMaxSize"]} instances"
#   actions_enabled     = var.asgRoleMap["aspCPUEnabled"]
#   alarm_actions       = concat(var.topicArnList,list(aws_autoscaling_policy.asg-policy_scale-out[0].arn))

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.asg.name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "cw_networkin_alarm" {
#    count               = var.asgRoleMap["aspNetInEnabled"] == "true" ? 1: 0
#    alarm_name          = "${lower(var.commonTags["oEnvironment"])}-asg-${lower(var.asgRoleMap["asgRole"])}-NETWORK-IN-BYTES-ZERO"
#    comparison_operator = "GreaterThanOrEqualToThreshold"
#    evaluation_periods  = var.asgScalingMap["scaleOutCwNetInAlarmEvalPeriodsCount"]
#    metric_name         = "NetworkIn"
#    namespace           = "AWS/EC2"
#    period              = var.asgScalingMap["scaleOutCwNetInAlarmEvalPeriodInSecs"]
#    statistic           = "Minimum"
#    threshold           = var.asgScalingMap["scaleOutCwNetInAlarmEvalThresholdPercent"]
#    alarm_description   = "Autoscaling Network In bytes% average was none ${var.asgScalingMap["scaleOutCwNetInAlarmEvalThresholdPercent"]}% for ${var.asgScalingMap["scaleOutCwNetInAlarmEvalPeriodsCount"] * var.asgScalingMap["scaleOutCwNetInAlarmEvalPeriodInSecs"]} seconds. Triggering scale OUT action unless we are at ${var.asgRoleMap["asgMaxSize"]} instances"
#    actions_enabled     = var.asgRoleMap["aspNetInEnabled"]
#    alarm_actions       = concat(var.topicArnList,list(aws_autoscaling_policy.asg-policy_scale-out[0].arn))

#    dimensions = {
#      AutoScalingGroupName = aws_autoscaling_group.asg.name
#    }
# }

# //# Scale In
# resource "aws_autoscaling_policy" "asg-policy_scale-in" {
#   count                  = var.asgRoleMap["aspEnabled"] == "true" ? 1: 0
#   name                   = "ASG-POLICY-SCALE-IN-${lower(var.asgRoleMap["asgRole"])}"
#   policy_type            = "SimpleScaling"
#   autoscaling_group_name = aws_autoscaling_group.asg.name
#   adjustment_type        = "ChangeInCapacity"
#   scaling_adjustment     = abs(var.asgScalingMap["aspScaleInNodesToRemove"]) * -1
#   cooldown               = var.asgScalingMap["aspScaleInCoolDown"]
# }

# resource "aws_cloudwatch_metric_alarm" "cw_cpu-low_alarm" {
#   count               = var.asgRoleMap["aspEnabled"] == "true" ? 1: 0
#   alarm_name          = "${lower(var.commonTags["oEnvironment"])}-asg-${lower(var.asgRoleMap["asgRole"])}-CPU-LOW"
#   comparison_operator = "LessThanThreshold"
#   evaluation_periods  = var.asgScalingMap["scaleInCwAlarmEvalPeriodsCount"]
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = var.asgScalingMap["scaleInCwAlarmEvalPeriodInSecs"]
#   statistic           = "Average"
#   threshold           = var.asgScalingMap["scaleInCwAlarmEvalThresholdPercent"]
#   alarm_description   = "Autoscaling CPU% average was under ${var.asgScalingMap["scaleInCwAlarmEvalThresholdPercent"]}% for ${var.asgScalingMap["scaleInCwAlarmEvalPeriodsCount"] * var.asgScalingMap["scaleInCwAlarmEvalPeriodInSecs"]} seconds. Triggering scale IN action unless we are already at ${var.asgRoleMap["asgMinSize"]} instances"
#   actions_enabled     = var.asgRoleMap["aspEnabled"]
#   alarm_actions       = concat(var.topicArnList,list(aws_autoscaling_policy.asg-policy_scale-in[0].arn))

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.asg.name
#   }
# }

### Autoscaling Scale Out/In Policies and CloudWatch Alarms
################################################################################
