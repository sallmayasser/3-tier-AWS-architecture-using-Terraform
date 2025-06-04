
variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true

}
variable "subnet-ids" {
  type        = list(string)
  description = "the list of subnets id to attach to the RDS"
}

variable "sg-id-list" {
  type        = list(string)
  description = "the list of db security group id that attached with db"
}

variable "azs" {
  type = list(string)
  description = "the list of AZs used for the Docdb "
}