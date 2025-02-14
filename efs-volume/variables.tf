variable "efs_name" {
  description = "Name of the EFS file system"
}

variable "efs_subnet_ids" {
  description = "IDs of the subnet where the EFS mount targets will be created"
  type        = list(string)
}

variable "efs_security_group_ids" {
  description = "List of security group IDs to attach to the EFS mount targets"
  type        = list(string)
}

variable "throughput_mode" {
  description = "List of security group IDs to attach to the EFS mount targets"
  type        = string
  default     = "elastic"
}
