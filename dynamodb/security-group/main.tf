locals {
  envName = var.commonTags["rEnvironmentName"]
}

#############################################################
### Security

resource "aws_security_group" "secGroup" {
  name        = "${local.envName}-secgroup-${var.sgAlias}"
  description = "Security Group"
  vpc_id      = var.vpcId
  tags        = merge(var.commonTags, map("uRole", "Security Group", "Name", "${local.envName}-secgroup-${var.sgAlias}"))
}

# Allow TCP from other security group(s) to this security group
resource "aws_security_group_rule" "inFromSg" {
  for_each                 = toset(concat(var.allowInSg, var.allowInSgWithReciprocal))
  type                     = "ingress"
  from_port                = element(split("_", each.value), 0)
  to_port                  = element(split("_", each.value), 1)
  protocol                 = element(split("_", each.value), 2)
  security_group_id        = aws_security_group.secGroup.id
  source_security_group_id = element(split("_", each.value), 3)
  description              = "For SG ${var.sgAlias}"
}

resource "aws_security_group_rule" "reciprocalSgOut" {
  for_each                 = toset(var.allowInSgWithReciprocal)
  type                     = "egress"
  from_port                = element(split("_", each.value), 0)
  to_port                  = element(split("_", each.value), 1)
  protocol                 = element(split("_", each.value), 2)
  security_group_id        = element(split("_", each.value), 3)
  source_security_group_id = aws_security_group.secGroup.id
  description              = "Reciprocal for SG ${var.sgAlias}"
}

# Allow TCP from this security group to other security group(s)
resource "aws_security_group_rule" "outToSg" {
  for_each                 = toset(concat(var.allowOutSg, var.allowOutSgWithReciprocal))
  type                     = "egress"
  from_port                = element(split("_", each.value), 0)
  to_port                  = element(split("_", each.value), 1)
  protocol                 = element(split("_", each.value), 2)
  security_group_id        = aws_security_group.secGroup.id
  source_security_group_id = element(split("_", each.value), 3)
  description              = "For SG ${var.sgAlias}"
}

resource "aws_security_group_rule" "reciprocalSgIn" {
  for_each                 = toset(var.allowOutSgWithReciprocal)
  type                     = "ingress"
  from_port                = element(split("_", each.value), 0)
  to_port                  = element(split("_", each.value), 1)
  protocol                 = element(split("_", each.value), 2)
  security_group_id        = element(split("_", each.value), 3)
  source_security_group_id = aws_security_group.secGroup.id
  description              = "Reciprocal for SG ${var.sgAlias}"
}

# Interface VPCE - the interface VPCE already allows all in from the VPC CIDR
resource "aws_security_group_rule" "sgOutToIntVpce" {
  for_each                 = toset(var.allowVpcEndpoints == "true" ? var.intVpceServices["serviceSgList"] : [])
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.secGroup.id
  source_security_group_id = each.value
  description              = "For SG ${var.sgAlias}"
}

# Gateway VPCE
resource "aws_security_group_rule" "sgOutToGwVpce" {
  for_each          = toset(var.allowVpcEndpoints == "true" ? var.gwVpceServicesPrefixes : [])
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.secGroup.id
  prefix_list_ids   = list(each.value)
  description       = "For SG ${var.sgAlias}"
}

# CIDR
resource "aws_security_group_rule" "inFromCidr" {
  for_each          = toset(var.allowInCidr)
  type              = "ingress"
  from_port         = element(split("_", each.value), 0)
  to_port           = element(split("_", each.value), 1)
  protocol          = element(split("_", each.value), 2)
  security_group_id = aws_security_group.secGroup.id
  cidr_blocks       = list(element(split("_", each.value), 3))
  description       = "For SG ${var.sgAlias}"
}

resource "aws_security_group_rule" "outToCidr" {
  for_each          = toset(var.allowOutCidr)
  type              = "egress"
  from_port         = element(split("_", each.value), 0)
  to_port           = element(split("_", each.value), 1)
  protocol          = element(split("_", each.value), 2)
  security_group_id = aws_security_group.secGroup.id
  cidr_blocks       = list(element(split("_", each.value), 3))
  description       = "For SG ${var.sgAlias}"
}

# Allow inbound/outbound within the same security group
resource "aws_security_group_rule" "roleAllInSelf" {
  count                    = lower(var.allowAllSelfToSelf) == "true" ? 1 : 0
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "65535"
  protocol                 = "all"
  security_group_id        = aws_security_group.secGroup.id
  source_security_group_id = aws_security_group.secGroup.id
  description              = "For SG ${var.sgAlias}"
}

resource "aws_security_group_rule" "roleAllOutSelf" {
  count                    = lower(var.allowAllSelfToSelf) == "true" ? 1 : 0
  type                     = "egress"
  from_port                = "0"
  to_port                  = "65535"
  protocol                 = "all"
  security_group_id        = aws_security_group.secGroup.id
  source_security_group_id = aws_security_group.secGroup.id
  description              = "For SG ${var.sgAlias}"
}

### Security
#############################################################
