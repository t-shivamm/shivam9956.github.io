output "user" {
  value = element(concat(aws_rds_cluster.primary.*.master_username, [""]), 0)
}

output "endpoint" {
  value = element(concat(aws_rds_cluster.primary.*.endpoint, [""]), 0)
}

output "name" {
  value = element(concat(aws_rds_cluster.primary.*.database_name, [""]), 0)
}
