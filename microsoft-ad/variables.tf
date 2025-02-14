variable "dnsRootDomain" {
  type        = string
  description = "Dummy description"
}

variable "ssmParamName_msAdAdminPass" {
  type        = string
  description = "Dummy description"
}

variable "ssmParamKmsKeyId_msAdAdminPass" {
  type        = string
  description = "Dummy description"
}

variable "adEdition" {
  type        = string
  description = "Dummy description"
}

variable "vpcId" {
  type        = string
  description = "Dummy description"
}

variable "adCndFwdDomains" {
  type        = map(any)
  description = "Dummy description"
}

variable "adSubnetIds" {
  type        = list(any)
  description = "Dummy description"
}

variable "intVpceInfo" {
  type        = map(any)
  description = "Dummy description"
}

variable "intVpceServices" {
  type        = map(any)
  description = "Dummy description"
}

variable "commonTags" {
  type        = map(any)
  description = "Dummy description"
}
