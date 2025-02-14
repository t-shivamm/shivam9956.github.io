
variable "commonTags" {
  type = map(any)
}

variable "asgAttr" {
  type = map(map(any))
}

variable "asgLaunchConfigs" {
  type = map(map(any))
}

variable "asgAttrTg" {
  type = map(map(any))
}

variable "asgScaling" {
  type = map(map(any))
}

variable "asgCloudwatch" {
  type = map(map(any))
}

variable "r53HostedZoneMap" {
  type = map(any)
}

variable "roleVariables" {
  type = map(any)
}

variable "tfAwsRegion" {
  type = string
}

variable "services_config" {
  type = map(any)
}

variable "dnsRootDomain" {
  type = string
}

variable "s3bucketnames" {
  type = list(string)
}

variable "ipsTrustedWeb" {
  type = list(string)
}

variable "tfAwsAccNo" {
  type = string
}

variable "ip_lists" {
  type = map(any)
}

variable "PublicR53ZoneName" {
  type = string
}

variable "asgAWSManagedPoliciesList" {
  type = list(string)
}

variable "ipsTrustedDevops" {
  type = list(string)
}

variable "mixedInstancePlansMap" {
  type = map(any)
}
=======
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
