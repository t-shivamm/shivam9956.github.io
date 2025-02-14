
variable "common_tags" {
  type        = map(string)
  description = "Common tags for any resource"
}

variable "role_name" {
  type        = string
  description = "Used in the naming of resources"
  default     = ""
}

variable "ebs_volume_defs" {
  type = map(object({
    device_name          = string,
    availability_zone    = string,
    instance_id          = string,
    encrypted            = any,
    iops                 = any,
    multi_attach_enabled = any,
    size                 = any,
    snapshot_id          = any,
    outpost_arn          = any,
    type                 = any,
    kms_key_id           = any,
    throughput           = any,
  }))
  description = "Define ebs volume(s) to create and optionally attach to an instance"
}
