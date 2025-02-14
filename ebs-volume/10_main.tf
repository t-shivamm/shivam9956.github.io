

#############################################################
### EBS volume

resource "aws_ebs_volume" "objs" {
  for_each = var.ebs_volume_defs

  availability_zone    = each.value["availability_zone"]
  encrypted            = each.value["encrypted"]
  iops                 = each.value["iops"]
  multi_attach_enabled = each.value["multi_attach_enabled"]
  size                 = each.value["size"]
  snapshot_id          = each.value["snapshot_id"]
  outpost_arn          = each.value["outpost_arn"]
  type                 = each.value["type"]
  kms_key_id           = each.value["kms_key_id"]
  throughput           = each.value["throughput"]

  tags = merge(
    var.common_tags,
    {
      uRole = "EBS Volume",
      Name  = join("-", compact([local.env_name, var.role_name, "ebs", each.key]))
    }
  )
}

resource "aws_volume_attachment" "objs" {
  for_each = var.ebs_volume_defs

  device_name = each.value["device_name"]
  instance_id = each.value["instance_id"]
  volume_id   = aws_ebs_volume.objs[each.key].id
}

### EBS volume
#############################################################
