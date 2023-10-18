#!/bin/bash

# Para que se muestren los comandos que se ejecutan:
set -x

# Actualizamos paquetes:
dnf update -y

#Instalar apache

dnf install httpd -y

# Iniciamos servicio apache

systemctl start httpd

# Configuramos para que el servicio inicie de forma automatica

systemctl enable httpd

#------------------
#Instalacion de Mysql server:

dnf install mysql-server -y

# Iniciamos servicio mysql server:

systemctl start mysqld

# Configuramos para que el servicio inicie de forma automatica

systemctl enable mysqld
#------------------

#--------------------
# Instalacion de PHP:

 dnf install php -y

 # Extensión de PHP para conectar con MySQL:

 dnf install php-mysqlnd -y

#---------------------

 # reiniciar el servicio de Apache para que se apliquen los cambios:

 systemctl restart httpd

 # copiar archivo info.php a /var/www/html/

 cp ../php/info.php /var/www/html

