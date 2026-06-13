#!/bin/bash

apt-get update
apt-get install apache2 -y
service apache2 restart

HOSTNAME=$(hostname)

echo "Page served from: $HOSTNAME" > /var/www/html/index.html