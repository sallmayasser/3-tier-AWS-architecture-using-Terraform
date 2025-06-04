variable "instance-type" {
  type        = string
  description = "the type of instance "
}

variable "my-key" {
  type        = string
  description = "the ec2 key pair name"
}

variable "security-group-ids" {
  type        = list(string)
  description = "the security group id "
}

variable "template-name" {
  type        = string
  description = "the name of the launch template"
}
variable "user-data" {
  type        = string
  description = "the user data script to run on instance launch"
}
variable "ASG-name" {
  type        = string
  description = "the name of the Auto Scaling Group"
}
variable "vpc-zone-ids" {
  type        = list(string)
  description = "the list of subnet ids for the auto scaling group"
}
variable "max_size" {
  type        = number
  description = "the maximum size of the Auto Scaling Group"
}
variable "min_size" {
  type        = number
  description = "the minimum size of the Auto Scaling Group"
}
variable "desired_capacity" {
  type        = number
  description = "the desired capacity of the Auto Scaling Group"
}

variable "target-grps-arn" {
  type        = list(string)
  description = "the list of target group ARNs to attach to thw Auto Scaling Group"
}
variable "instance-name" {
  type        = string
  description = "the name of the instance to be tagged in ASG"
}
