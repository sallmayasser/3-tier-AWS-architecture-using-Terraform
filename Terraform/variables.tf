#  Network module variables 
variable "aws-region" {
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

# EC2 module variables 
variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}
variable "instance-type" {
  type = string
  description = "the type of instance"
}

# database variable 
variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true

}
