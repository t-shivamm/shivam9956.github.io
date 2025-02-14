# FYI - accessing the SSM Parameter via VPC endpoint


## Powershell
The wrapper userdata file "template_win.txt" should contain the function getVpcSsmParamValue to do this but the meat of that function is this:
(Get-SSMParameter -Name $paramName -WithDecryption $param -region $instanceRegion -EndpointUrl $ssmParamVPCEndpointUrl).value
