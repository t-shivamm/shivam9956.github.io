resource "aws_efs_file_system" "shared_efs" {
  encrypted       = "true"
  throughput_mode = var.throughput_mode
  tags = {
    Name = var.efs_name
  }
  lifecycle {
    ignore_changes = [throughput_mode]
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each        = toset(var.efs_subnet_ids)
  file_system_id  = aws_efs_file_system.shared_efs.id
  subnet_id       = each.key
  security_groups = var.efs_security_group_ids
}
