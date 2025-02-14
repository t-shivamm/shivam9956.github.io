output "user" {
  value = element(concat(aws_db_instance.default.*.username, [""]), 0)
}

output "password" {
  value = element(concat(aws_db_instance.default.*.password, [""]), 0)
}

output "endpoint" {
  value = element(concat(aws_db_instance.default.*.endpoint, [""]), 0)
}
