output "ebs_volume-objs" {
  value = aws_ebs_volume.objs
}

output "ebs_vol-to-instance-map" {
  value = {
    for k, v in aws_volume_attachment.objs
    : k => {
      volume_id   = v.volume_id
      instance_id = v.instance_id
      device_name = v.device_name
    }
  }
}
