#This terraform creates all the new policies using the .json files located in the same directory as this file.

#Creates a policy for devs with extra permissions it will also users which will force the use of multi factor authorisation before they can see them.
resource "aws_iam_policy" "cicd_deployments" {
  name        = "CICD-Deployments-Policy"
  description = "This policy is for the CICD-Deployments user permissions"
  policy      = file("cicd-deployments.json")
}

#Attaches the MFA policy to the new group DevOpsAdministrator.
resource "aws_iam_user_policy_attachment" "attach-policy" {
  user       = aws_iam_user.cicd-deployments.name
  policy_arn = aws_iam_policy.cicd_deployments.arn
}
