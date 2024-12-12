#!/bin/bash

# Muestra todos los comandos que se van ejecutando
set -ex

#Actualizar repo
apt update

#Actualizar paquetes
# apt upgrade -y

# Importamos el archivo de variables .env
source .env

#Instalamos cloudwatch agent
wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -P /tmp/
dpkg -i /tmp/amazon-cloudwatch-agent.deb

# Mover archivo de configuracion a cloudwatch agent
cp ../json/config.json /opt/aws/amazon-cloudwatch-agent/bin/

# Configurar cloudwatch
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

# Configurar logs para que vayan en formato json
sed -i '/LogFormat "{ \"remote_addr\": \"%h\", \"remote_user\": \"%u\", \"time_local\": \"%{%d\/%b\/%Y:%H:%M:%S}t\", \"request\": \"%r\", \"status\": \"%>s\", \"body_bytes_sent\": \"%b\", \"http_referer\": \"%{Referer}i\", \"http_user_agent\": \"%{User-Agent}i\" }" json/d' /etc/apache2/apache2.conf
sed -i '/ErrorLogFormat "{\"time\":\"%{%usec_frac}t\", \"function\" : \"[%-m:%l]\", \"process\" : \"[pid%P]\" ,\"message\" : \"%M\"}"/d' /etc/apache2/apache2.conf
sed -i '/CustomLog \/var\/log\/apache2\/access.log json/d' /etc/apache2/apache2.conf
echo 'LogFormat "{ \"remote_addr\": \"%h\", \"remote_user\": \"%u\", \"time_local\": \"%{%d/%b/%Y:%H:%M:%S}t\", \"request\": \"%r\", \"status\": \"%>s\", \"body_bytes_sent\": \"%b\", \"http_referer\": \"%{Referer}i\", \"http_user_agent\": \"%{User-Agent}i\" }" json' | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo 'ErrorLogFormat "{\"time\":\"%{%usec_frac}t\", \"function\" : \"[%-m:%l]\", \"process\" : \"[pid%P]\" ,\"message\" : \"%M\"}"' | sudo tee -a /etc/apache2/apache2.conf > /dev/null
echo 'CustomLog /var/log/apache2/access.log json' | sudo tee -a /etc/apache2/apache2.conf > /dev/null

# Actualizar permisos
sudo chmod 644 /var/log/apache2/access.log
sudo chmod 644 /var/log/apache2/error.log

# Reiniciar cloudwatch
systemctl restart amazon-cloudwatch-agent

# Reiniciar Apache
systemctl restart apache2