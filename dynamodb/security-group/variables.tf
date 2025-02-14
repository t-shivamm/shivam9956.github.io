variable "sgAlias" {
  type        = string
  description = "For naming the security group"
}

variable "allowVpcEndpoints" {
  type        = string
  description = "If true then add rules to allow to the VPC Endpoints"
  default     = "true"
}

variable "vpcId" {
  type        = string
  description = "ID of the VPC to create the security groups within"
}

variable "allowInSg" {
  type        = list(string)
  description = "Creates allow IN rules for this SG. Define in the format fromport_toport_proto_secgroupid e.g. 443_443_tcp_sg-123456678"
  default     = []
}

variable "allowInSgWithReciprocal" {
  type        = list(string)
  description = "Creates allow IN rules for this SG and OUT rules for the other SG. Define in the format fromport_toport_proto_secgroupid e.g. 443_443_tcp_sg-123456678"
  default     = []
}

variable "allowOutSg" {
  type        = list(string)
  description = "Creates allow OUT rules for this SG. Define in the format fromport_toport_proto_secgroupid e.g. 443_443_tcp_sg-123456678"
  default     = []
}

variable "allowOutSgWithReciprocal" {
  type        = list(string)
  description = "Creates allow OUT rules for this SG and IN rules for the other SG. Define in the format fromport_toport_proto_secgroupid e.g. 443_443_tcp_sg-123456678"
  default     = []
}

variable "allowInCidr" {
  type        = list(string)
  description = "Creates allow OUT rules for this SG. Define in the format fromport_toport_proto_cidr e.g. 53_53_udp_8.8.8.8/32"
  default     = []
}

variable "allowOutCidr" {
  type        = list(string)
  description = "Creates allow IN rules for this SG. Define in the format fromport_toport_proto_cidr e.g. 443_443_tcp_0.0.0.0/32"
  default     = []
}

variable "intVpceServices" {
  type        = map(list(string))
  description = "Create allow OUT rules for interface VPC endpoint security groups. Map must contain key serviceSgList with list of those SG IDs"
  default = {
    serviceNameList = []
    serviceDnsList  = []
    serviceSgList   = []
  }
}

variable "gwVpceServicesPrefixes" {
  type        = list(string)
  description = "Create allow OUT rules for gateway VPC endpoint prefixes. List elements must be the prefix IDs"
  default     = []
}

variable "allowAllSelfToSelf" {
  type        = string
  description = "Set to true|false to control whether members within this SG are allowed unrestricted"
}

variable "commonTags" {
  type        = map(string)
  description = "Map of common tags to be applied to all resources"
}
