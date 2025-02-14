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
