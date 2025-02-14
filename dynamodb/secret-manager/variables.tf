variable "prefix" {
  type        = string
  description = "Prefix for the name of the secrets"
}

variable "names" {
  type        = list(string)
  description = "List of unique names for the secrets. Will be converted to lower case and spaces will replaced by '-'."
}

variable "value" {
  type        = object({})
  description = "The json value of the secrets (this should be a placeholder that will later be replaced)"
}
