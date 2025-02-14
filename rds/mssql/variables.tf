variable "mssql_instance_identifier" {
  type        = string
  description = "The identifier for the mssql instance."
}

variable "database_name" {
  type = string
}

variable "database_user" {
  type = string
}

variable "database_password" {
  type = string
}

variable "aws_security_group_ids" {
  type        = list(string)
  description = "List of VPC security groups to associate with the Cluster."
}

variable "aws_subnet_ids" {
  type        = list(string)
  description = "A list of subnets to put in the RDS's subnet group."
}

variable "instance_class" {
  type        = string
  default     = "db.t2.medium"
  description = "https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html"
}

variable "database_active" {
  type = string
}

variable "multi_az" {
  type        = string
  default     = "true"
  description = "If the DB instance should be stretched across multiple AZs. If true then this will significantly increase the price"
}

variable "allocated_storage" {
  type        = string
  default     = "3"
  description = "The amount of storage in gibibytes to allocate for the database - minimum is 2.5 for 20 gigabytes of storage"
}
variable "engine" {
  type        = string
  default     = "sqlserver-se"
  description = "The MsSQL version number i.e. 14.00.1000.169.v1"
}
variable "engine_version" {
  type        = string
  description = "The MsSQL version number i.e. 14.00.1000.169.v1"
}
variable "port" {
  type = string
}
variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}
variable "license_model" {
  description = "License model information for this DB instance. Optional, but required for some DB engines, i.e. Oracle SE1"
  type        = string
  default     = "License-Included"
}
variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 30
}
variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = true
}
variable "apply_immediately" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "parameter_group_family" {
  type        = string
  description = "The parameter group family, i.e. mysql8.0"
}

variable "xtra_parameters" {
  type        = list(map(string))
  default     = []
  description = "list of custom parameters group other than default ones"
}

variable "rds_instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance."
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}