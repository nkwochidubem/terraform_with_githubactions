output "wordpress_url" {
  value = "http://${module.wordpress.public_ip}"
}
