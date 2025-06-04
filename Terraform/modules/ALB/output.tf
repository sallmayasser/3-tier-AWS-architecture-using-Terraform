output "alb-dns" {
  value       = aws_lb.my-ALB.dns_name
  description = "the dns of the ALB "
}
output "target_group_arn" {
  value = aws_lb_target_group.my-target-group.arn
  description = "the ARN of the Target Group"
}