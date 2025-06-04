variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = "security group"
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ingress_rules" {
  description = "A list of ingress rules"
  type = map(object({
    cidr_ipv4                    = string
    referenced_security_group_id = string
    from_port                    = number
    ip_protocol                  = string
    to_port                      = number
  }))
  default = {}
}


variable "egress_rules" {
  description = "A list of egress rules"
  type = map(object({
    cidr_ipv4   = string
    ip_protocol = string
  }))

  default = {
    default = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }
}
