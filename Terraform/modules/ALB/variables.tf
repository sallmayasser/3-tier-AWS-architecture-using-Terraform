variable "alb-name" {
  type        = string
  description = "value of AlB name"
}

variable "isInternal" {
  type = bool
}

variable "security-group-ids" {
  type        = list(string)
  description = "the list of security group id to attach to the ALB"
}

variable "subnet-ids" {
  type        = list(string)
  description = "the list of subnets id to attach to the ALB"
}

variable "target-gp-name" {
  type        = string
  description = "the name of target group"
}
variable "port" {
  type = number
  description = "the port number of target group"
}
variable "listener-port" {
  type = number
  description = "the port number of target group"
}
variable "vpc-id" {
  type        = string
  description = "the id of Vpc"
}

variable "health_check_config" {
  description = "Health check configuration for the target group"
  type = object({
    path                = string
    protocol            = string
    port                = number
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    matcher             = string
  })
}
