#Create the CICD-Deployments user for use in the DeployToPROD stages of the cicd pipelines
resource "aws_iam_user" "cicd-deployments" {
  name = "CICD-Deployments"
}
