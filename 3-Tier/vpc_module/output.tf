output "vpc_id" {
  value = aws_vpc.three_tier.id
}

output "subnet_id" {
  value = aws_subnet.privateappaz1.id
}

output "security_private_instance" {
  value = aws_security_group.private_instance.id
}

output "security_internet" {
  value = aws_security_group.internet.id
}

output "security_webtier" {
  value = aws_security_group.web_tier.id
}

output "internal_lb_sg" {
  value = aws_security_group.internal_lb.id
}

output "security_database" {
  value = aws_security_group.database.id
}

output "database_grp_name" {
  value = aws_db_subnet_group.name.id
}

output "subnet_app_az2" {
  value = aws_subnet.private_app_az2
}