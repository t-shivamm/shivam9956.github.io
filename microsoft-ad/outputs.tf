output "ipList" {
  value = aws_directory_service_directory.microsoft-ad.dns_ip_addresses
}

output "sgId" {
  value = aws_directory_service_directory.microsoft-ad.security_group_id
}

output "id" {
  value = aws_directory_service_directory.microsoft-ad.id
}

output "name" {
  value = aws_directory_service_directory.microsoft-ad.name
}

output "iamPolArn_readDecryptSsmParamMsAdAdminPass" {
  value = aws_iam_policy.iamPol_readDecryptSsmParamMsAdAdminPass.arn
}
