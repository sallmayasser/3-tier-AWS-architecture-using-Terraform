output "docDb-endpoint" {
  value       = aws_docdb_cluster.docdb.endpoint
  description = "the my DocumentDb endpoint "
}
output "ssm_param_name" {
  value = aws_ssm_parameter.mongo_uri.name
  
}