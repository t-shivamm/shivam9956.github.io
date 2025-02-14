output "id" {
  value = aws_efs_file_system.shared_efs.id
}

output "mount_targets_network_interface_ids" {
  value = {
    for mount_target in aws_efs_mount_target.efs_mount_target :
    mount_target.availability_zone_id => mount_target.network_interface_id
  }
}
