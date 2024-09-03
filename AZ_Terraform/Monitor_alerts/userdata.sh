#!/bin/bash
# Update package list
sudo apt-get update

# Install Nginx
sudo apt-get install nginx -y
# Start Nginx
systemctl enable nginx
systemctl start nginx

# Write a custom index.html file
echo "<html><body><h1>Hello from Terraform vm1</h1></body></html>" > /var/www/html/index.html
