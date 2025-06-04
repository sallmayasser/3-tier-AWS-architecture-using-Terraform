output "vpc-id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my-vpc.id
}

output "public-subnet-id-1" {
  description = "The ID of the public subnet 1"
  value       = aws_subnet.subnets["public-subnet-1"].id
}
output "public-subnet-id-2" {
  description = "The ID of the public subnet 2"
  value       = aws_subnet.subnets["public-subnet-2"].id
}
output "private-subnet-id-1" {
  description = "The ID of the private subnet 1"
  value       = aws_subnet.subnets["private-subnet-1"].id
}
output "private-subnet-id-2" {
  description = "The ID of the private subnet 2"
  value       = aws_subnet.subnets["private-subnet-2"].id
}
output "db-subnet-id-1" {
  description = "The ID of the DB subnet 1"
  value       = aws_subnet.subnets["private-subnet-1"].id
}
output "db-subnet-id-2" {
  description = "The ID of the DB subnet 2"
  value       = aws_subnet.subnets["private-subnet-2"].id
}
