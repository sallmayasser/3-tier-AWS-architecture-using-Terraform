resource "aws_lb" "my-ALB" {
  name                       = var.alb-name
  internal                   = var.isInternal
  load_balancer_type         = "application"
  security_groups            = var.security-group-ids
  subnets                    = var.subnet-ids
  enable_deletion_protection = false

}

resource "aws_lb_target_group" "my-target-group" {
  name        = var.target-gp-name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc-id
  target_type = "instance"
  health_check {
    path                = var.health_check_config.path
    port                = var.health_check_config.port
    protocol            = var.health_check_config.protocol
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    matcher             = var.health_check_config.matcher
  }
}


resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.my-ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
