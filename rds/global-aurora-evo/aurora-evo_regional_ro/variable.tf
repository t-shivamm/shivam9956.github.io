variable "cluster_instance_identifier" {
  type        = string
  description = "The identifier for the RDS instance."

}

variable "cluster_identifier" {
  type        = string
  description = "The identifier for the RDS cluster."

}

variable "aws_subnet_ids" {
  type        = list(string)
  description = "A list of subnets to put in the RDS's subnet group."
}
variable "global_cluster_id" {
  type        = string
  description = "global cluster id, used to reference regional replicas with the global cluster"

}

variable "global_cluster_engine" {
  type        = string
  description = "The identifier for the global RDS cluster."

}


variable "global_cluster_engine_version" {
  type        = string
  description = "global cluster engine version"

}


variable "instance_class" {
  type        = string
  description = "The instance class for the database, i.e. db.t2.micro"

}

variable "regional_ro_replica" {
  type        = string
  description = "variable to determine if regional replicas will be deployed."

}
