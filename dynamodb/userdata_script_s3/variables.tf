
variable "s3_script_alias" {
  type        = string
  description = "The unique alias for the rendered userdata script which will be stored in s3"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for storing the userdata scripts"
}

variable "wrapper_script_name" {
  type        = string
  description = "Name of the wrapper template file - which will for the complete userdata"
}

variable "wrapper_script_vars" {
  type        = map(any)
  description = "Variables for the wrapper template file"
}

variable "role_script_name" {
  type        = string
  description = "Name of the role template file - which will for the complete userdata"
}
