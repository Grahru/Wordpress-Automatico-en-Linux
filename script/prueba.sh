#!/bin/bash

#Muestra todos los comandos que se van ejecutando
set -ex

# Importamos el archivo de variables .env
source .env
#Copiar archivo de conf
cp ../conf/000-default.conf /etc/apache2/sites-available

# Reemplazamos los valores de la plantilla con las direcciones ip de las frontales
sed -i "s(CERTIFICATE_DOMAIN($CERTIFICATE_DOMAIN(" /etc/apache2/sites-available/000-default.conf
sed -i "s(Path_private_key($Path_private_key(" /etc/apache2/sites-available/000-default.conf
sed -i "s(Path_certificate($Path_certificate(" /etc/apache2/sites-available/000-default.conf
sed -i "s(Path_chain($Path_chain(" /etc/apache2/sites-available/000-default.conf

cat /etc/apache2/sites-available/000-default.conf