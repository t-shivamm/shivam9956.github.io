
variable "roleVariables" {
  type = map(any)
}

variable "tfAwsRegion" {
  type = string
}

variable "commonTags" {
  type = map(any)
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "namespace" {
  type        = string
  description = "Namespace (e.g. `eg` or `cp`)"
  default     = "TE-Sitecore"
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = "uat"
}

variable "name" {
  type        = string
  description = "Name of the application"
  default     = "sitecore_mongodb"
}
