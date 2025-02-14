# Definition of the secret
resource "aws_secretsmanager_secret" "module_secret" {
  name                    = "${var.prefix}${replace(lower(var.names[count.index]), "/[\\s\\(\\)]/", "-")}"
  recovery_window_in_days = "30"

  count = length(var.names)
}

# Definition of the secret value
resource "aws_secretsmanager_secret_version" "module_secret_aws_client" {
  secret_id     = aws_secretsmanager_secret.module_secret[count.index].id
  secret_string = jsonencode(var.value)

  count = length(var.names)
}
