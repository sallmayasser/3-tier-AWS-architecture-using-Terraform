resource "aws_security_group" "mySG" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = var.tags
}


#//////////////////////////// Creating inbound rules ///////////////////////////


resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.mySG.id
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  to_port                      = each.value.to_port
}


#////////////////////////////// Creating outbound rules ////////////////////////


resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  for_each = var.egress_rules

  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
}
