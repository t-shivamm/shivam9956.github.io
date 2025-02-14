
variable "common_tags" {
  type        = map(any)
  description = "Common tags"
}

variable "lambda_function_config" {
  type        = map(any)
  description = "Configuration types for the lambda function"
}

variable "lambda_trigger_cron_pattern" {
  type        = string
  description = "Cron pattern defining when to trigger the lambda e.g. 0 11 ? * * *"
}

variable "cw_alarm_sns_topic_arn_list" {
  type        = list(any)
  description = "SNS Topic ARN(s) to notify for any Lambda execution errors. Leave empty to disable."
  default     = []
}

variable "enable_set_retention_action" {
  type        = string
  description = "Set to true to enable lambda to actually set retention values. False is useful for testing/debugging as it will log what it would've done"
}

variable "classification_json" {
  type        = string
  description = "Json selecting log groups by name regex and optionally overriding the default log retention period"
}
