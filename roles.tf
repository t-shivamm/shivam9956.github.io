###EC2 Instance role per service
###CommonAWS Managed Policy + CommonENVLevelPolicy +AppSpecificAWSMAnagedPolicy + CustomSpecificAPPLevelPolicy = App Role
locals {

  appManagedPoliciesList = []

  allManagedPoliciesList = concat(var.asgAWSManagedPoliciesList, local.appManagedPoliciesList)

}
####Define App Role#####
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.commonTags["oEnvironment"]}_${local.role_name}_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "${var.commonTags["oEnvironment"]}_${local.role_name}_role"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Effect": "Allow",
       "Principal": {
         "Service": "ec2.amazonaws.com"
       },
       "Action": "sts:AssumeRole"
     }
   ]
}
EOF
}



###########App IAM Policy
data "aws_iam_policy_document" "app_policy_document" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::sitecode.${var.commonTags.oEnvironment}.te-general.com/common/appd/*",
      "arn:aws:s3:::sitecode.${var.commonTags.oEnvironment}.te-general.com/${local.role_name}/*",
      "arn:aws:s3:::${var.commonTags["oEnvironment"]}-appdynamics"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::sitecode.${var.commonTags.oEnvironment}.te-general.com/${local.role_name}/*",
      "arn:aws:s3:::sitecode.${var.commonTags.oEnvironment}.te-general.com/common/*",
      "arn:aws:s3:::${var.roleVariables.appdBucketName}/*"
    ]
  }

  statement {
    sid     = "readDecryptSsmpSecureUserdata"
    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = distinct(concat(
      formatlist("arn:aws:ssm:${var.tfAwsRegion}:${data.aws_caller_identity.current.account_id}:parameter%s",
        concat(
          [
            "/${var.commonTags["oEnvironment"]}/in/secure/role_attributes/userdata/appd_account_password",
            "/${var.commonTags["oEnvironment"]}/in/secure/role_attributes/userdata/*",
            "/${var.commonTags["oEnvironment"]}/*/secure/role/singleusepass_evo/*",
            "/${var.commonTags["oEnvironment"]}/*/secure/role/${local.role_name}/*",
            "/${var.commonTags["oEnvironment"]}/in/secure/role_attributes/${local.role_name}/*",
            "/${var.commonTags["oEnvironment"]}/in/secure/role_credentials/${local.role_name}/*",
            "/${var.commonTags["oEnvironment"]}/*/secure/role/${local.role_name}/*",
            "/${var.commonTags["oEnvironment"]}/in/secure/role_attributes/${local.role_name}/*",
            "/${var.commonTags["oEnvironment"]}/in/secure/role_credentials/${local.role_name}/*",
          ],
          [for k, v in local.service_specific_args_ssm : v.ssmp_name] # service_specific_args_ssm
        )
      )
    ))
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "app-policy" {
  name   = "${var.commonTags["oEnvironment"]}_${local.role_name}_policy"
  policy = data.aws_iam_policy_document.app_policy_document.json
}

#####Policy Attachment####
resource "aws_iam_role_policy_attachment" "all-managed-policies-attach" {
  for_each   = toset(local.allManagedPoliciesList)
  role       = aws_iam_role.role.id
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "common-aws-managed-policies-attach" {
  role       = aws_iam_role.role.id
  policy_arn = data.terraform_remote_state.core_3.outputs.sto-string-common_policyArn
}

resource "aws_iam_role_policy_attachment" "app-policies-attach" {
  role       = aws_iam_role.role.id
  policy_arn = aws_iam_policy.app-policy.arn
}
