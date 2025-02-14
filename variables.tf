variable "isWindows" {
  type        = string
  description = "Dummy description"
}

variable "lcAmiId" {
  type        = string
  description = "Dummy description"
}

variable "lcIamInstanceProfile" {
  type        = string
  description = "Dummy description"
}

variable "topicArnList" {
  type        = list(any)
  description = "Dummy description"
}

variable "asgLcMap" {
  type        = map(any)
  description = "Dummy description"
}

variable "asgRoleMap" {
  type        = any
  description = "Dummy description"
}

variable "asgScalingMap" {
  type        = map(any)
  description = "Dummy description"
}

variable "asgCloudwatchMap" {
  type        = map(any)
  description = "Dummy description"
}

variable "commonTags" {
  type        = map(any)
  description = "Dummy description"
}

variable "tiersbntGrpListMap" {
  type        = map(any)
  description = "DFummy description"
}

variable "sgIdList" {
  type        = list(any)
  description = "DFummy description"
}

variable "userdata_s3" {
  type        = object({ script_s3_bucket = string, script_s3_key = string })
  description = "Defines the userdata_s3 script to call from the userdata script"
}

variable "aspDevEnvironment" {
  type    = string
  default = "false"
}

variable "enableScaleUp" {
  type    = string
  default = "true"
}

variable "enableScaleDown" {
  type    = string
  default = "true"
}

variable "HealthCheckType" {
  type    = string
  default = "ELB"
}

variable "aspTGResourceLabel" {
  type    = string
  default = ""
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default     = {}
}