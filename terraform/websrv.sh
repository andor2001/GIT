#!/bin/bash
apt update
apt install nginx -y
echo "Hi Bro" > /var/www/html/index.html
