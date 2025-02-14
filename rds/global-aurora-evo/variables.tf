variable "az_replicas" {
  type        = string
  description = "This set the number of replicas in the other AZ in same region"
}

variable "aws_vpc_id" {
  type        = string
  description = "The VPC id for the MySQL DB."
}

variable "cluster_instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance."

}

variable "cluster_identifier" {
  type        = string
  description = "The identifier for the RDS cluster."

}


variable "global_cluster_identifier" {
  type        = string
  description = "The identifier for the global RDS cluster."

}

variable "engine_version" {
  type        = string
  description = "The aurora version number"
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

variable "regional_ro_replica" {
  type        = string
  default     = "false"
  description = "If the DB instance should be stretched across multiple regions. If true then this will significantly increase the price"
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

variable "instance_xtra_parameters" {
  type        = list(map(string))
  default     = []
  description = "list of custom parameters group other than default ones, for the instance"
}
variable "cluster_xtra_parameters" {
  type        = list(map(string))
  default     = []
  description = "list of custom parameters group other than default ones, for the cluster"
}

variable "sns_topics" {
  type        = map(string)
  default     = {}
  description = "The SNS topics used for rds alerting"
}
