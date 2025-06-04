output "ext-dns" {
  description = "the External Alb dns "
  value       = "http://${module.pub-alb.alb-dns}"
}
output "int-dns" {
  description = "the Internal dns "
  value       = "http://${module.priv-alb.alb-dns}"
}

output "DocumentDb-endpoint" {
  description = "the mysql endpoint"
  value = module.databases.docDb-endpoint
}
