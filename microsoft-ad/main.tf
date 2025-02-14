locals {
  envName = lower(var.commonTags["rEnvironmentName"])
}

###############################################################
### Active Direcotry Service

data "aws_ssm_parameter" "ssmParamName_msAdAdminPass" {
  name            = var.ssmParamName_msAdAdminPass
  with_decryption = true
}

data "aws_kms_key" "ssmParamKmsKey_msAdAdminPass" {
  key_id = var.ssmParamKmsKeyId_msAdAdminPass
}

resource "aws_directory_service_directory" "microsoft-ad" {
  type     = "MicrosoftAD"
  name     = var.dnsRootDomain
  password = data.aws_ssm_parameter.ssmParamName_msAdAdminPass.value
  edition  = var.adEdition
  tags     = merge(var.commonTags, map("uRole", "MicrosoftAD ", "Name", "${local.envName}-msAd-${replace(var.dnsRootDomain, ".", "-")}"))

  vpc_settings {
    vpc_id     = var.vpcId
    subnet_ids = var.adSubnetIds
  }
}

### Active Directory Service
###############################################################

###############################################################
### Conditional Forwarders

## Interface VPCE Conditional Forwarders
resource "aws_directory_service_conditional_forwarder" "intVpceCondFwder" {
  count              = length(var.intVpceServices["serviceDnsList"])
  directory_id       = aws_directory_service_directory.microsoft-ad.id
  remote_domain_name = "${element(var.intVpceServices["serviceDnsList"], count.index)}.${var.intVpceInfo["serviceNameDomainSuffix"]}"
  dns_ips            = list(var.intVpceInfo["vpcAwsDnsSvrIp"])
}

resource "aws_directory_service_conditional_forwarder" "cndFwder" {
  count              = length(var.adCndFwdDomains["delimStrlist"])
  directory_id       = aws_directory_service_directory.microsoft-ad.id
  remote_domain_name = replace(element(split("_", element(var.adCndFwdDomains["delimStrlist"], count.index)), 0), "/[.]$/", "")
  dns_ips            = list(element(split("_", element(var.adCndFwdDomains["delimStrlist"], count.index)), 1))
}

### Conditional Forwarders
###############################################################

###############################################################
### IAM Policy - allow SSM Parameter read and KMS decrypt to the Microsoft Ad Password
data "aws_iam_policy_document" "iamPolDoc_readDecryptSsmParamMsAdAdminPass" {
  statement {
    sid       = "readSsmParam"
    effect    = "Allow"
    actions   = list("ssm:GetParameter")
    resources = list(data.aws_ssm_parameter.ssmParamName_msAdAdminPass.arn)
  }

  statement {
    sid       = "DecryptUsingKmsKey"
    effect    = "Allow"
    actions   = list("kms:DescribeKey", "kms:Decrypt")
    resources = list(data.aws_kms_key.ssmParamKmsKey_msAdAdminPass.arn)
  }
}

resource "aws_iam_policy" "iamPol_readDecryptSsmParamMsAdAdminPass" {
  name   = "readDecryptSsmParamMsAdAdminPass-${local.envName}"
  path   = "/"
  policy = data.aws_iam_policy_document.iamPolDoc_readDecryptSsmParamMsAdAdminPass.json
}

### IAM Policy - allow SSM Parameter read and KMS decrypt to the Microsoft Ad Password
###############################################################
