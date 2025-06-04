variable "region" {
  type    = string
  default = ""
}

variable "vpc-cidr" {
  type    = string
  default = ""
}

variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
    az         = string
  }))
}
