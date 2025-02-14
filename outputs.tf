output "asgId" {
  value = aws_autoscaling_group.asg.id
}

output "asgName" {
  value = aws_autoscaling_group.asg.name
}

output "asgAttributes" {
  value = {
    max_size = aws_autoscaling_group.asg.max_size
    min_size = aws_autoscaling_group.asg.max_size
  }
}
