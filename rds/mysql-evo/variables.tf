variable "database_active" {
  type = string
}

variable "aws_vpc_id" {
  type        = string
  description = "The VPC id for the MySQL DB."
}

variable "rds_instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance."
}

variable "allocated_storage" {
  type        = string
  default     = "3"
  description = "The amount of storage in gibibytes to allocate for the database - minimum is 2.5 for 20 gigabytes of storage"
}

variable "storage_alert_threshold" {
  type        = string
  default     = 5
  description = "The amount of free storage in gibibytes where we begin to alert"
}

variable "sns_topics" {
  type        = map(string)
  default     = {}
  description = "The SNS topics used for rds alerting"
}

variable "max_allocated_storage" {
  type        = string
  default     = null
  description = "Specifying a number larger than var.allocated_storage will enable RDS storage auto-scaling"
}


variable "engine_version" {
  type        = string
  description = "The MySQL version number i.e. 8.0.11."
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

variable "aws_subnet_ids" {
  type        = list(string)
  description = "A list of subnets to put in the RDS's subnet group."
}

variable "aws_security_group_ids" {
  type        = list(string)
  description = "A list of security groups to add to the RDS."
}

variable "instance_class" {
  type        = string
  description = "The instance class for the database, i.e. db.t2.micro"
}

variable "parameter_group_family" {
  type        = string
  description = "The parameter group family, i.e. mysql8.0"
}

variable "deletion_protection" {
  type        = string
  default     = "false"
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
}

variable "multi_az" {
  type        = string
  default     = "true"
  description = "If the DB instance should be stretched across multiple AZs. If true then this will significantly increase the price"
}


variable "storage_encrypted" {
  type        = string
  description = "Whether the db storage should be encrypted at rest using the default KMS key"
}


variable "apply_immediately" {
  description = "The database can't be deleted when this value is set to true."
  type        = bool
  default     = false
}

variable "commonTags" {
  type        = map(any)
  description = "Dummy description"
}

variable "xtra_parameters" {
  type        = list(map(string))
  default     = []
  description = "list of custom parameters group other than default ones"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  type        = bool
  default     = true
}