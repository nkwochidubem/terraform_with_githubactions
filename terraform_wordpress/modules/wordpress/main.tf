
############################
# WordPress EC2
############################
resource "aws_instance" "this" {
  ami           = "ami-07ff62358b87c7116"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  security_groups = [var.sg_id]
  associate_public_ip_address = true
  key_name      = var.key_name
 
  #depends_on = [aws_db_instance.wordpress] 
  #depends_on = var.rds_endpoint

user_data = <<-EOF
#!/bin/bash
#dnf install -y httpd php php-mysqlnd mysql wget tar
dnf install -y httpd php php-mysqlnd php-fpm php-json php-gd php-mbstring php-xml wget tar
systemctl enable httpd
systemctl start httpd

setsebool -P httpd_can_network_connect_db 1

cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* /var/www/html/
chown -R apache:apache /var/www/html

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${var.db_name}/" wp-config.php
sed -i "s/username_here/${var.db_user}/" wp-config.php
sed -i "s/password_here/${var.db_password}/" wp-config.php
sed -i "s/localhost/${var.db_host}/" wp-config.php


EOF

  tags = {
    Name = "WordPressServer"
  }
}

