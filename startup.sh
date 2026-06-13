#!/bin/bash

apt-get update
apt-get install apache2 -y
service apache2 restart

HOSTNAME=$(hostname)

echo "<h3>Servidor da web: $HOSTNAME</h3>" > /var/www/html/index.html