output "wordpress_sg_id" {
  value = aws_security_group.wordpress.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
