#!/bin/bash

# Para que se muestren los comandos que se ejecutan:
set -x

# importar variables

source .env

# Actualizamos paquetes:
dnf update -y

 # Instalamos los módulos de PHP necesarios para phpMyAdmin:

 dnf install php-mbstring php-zip php-json php-gd php-fpm php-xml -y

# Reiniciamos el servicio para detecte los nuevos modulos

systemctl restart httpd

# Instalamos la utilidad wget

dnf install wget -y

# Eliminar descargas previas de phpMyadmin
rm -rf /tmp/phpMyAdmin-5.2.1-all-languages.zip

# Eliminamos instalaciones previas de phpMyAdmin

rm -rf /var/www/html/phpmyadmin

# Descargamos el código fuente de phpMyAdmin.

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -P /tmp

# Instalamos utilidad unzip para descomprimirlo:

dnf install unzip -y

# Descompresión del archivo:

unzip -u /tmp/phpMyAdmin-5.2.1-all-languages.zip -d /var/www/html

# Renombrar directorio phpmyadmin

mv /var/www/html/phpMyAdmin-5.2.1-all-languages /var/www/html/phpmyadmin

# Actualización de lso permisos de /var/www/html

chown -R apache:apache /var/www/html

# Construimos la base de datos para complementar el codigo fuente de phpmyadmin

cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php


# Generamos un valor aleatorio de 32 caracteres para la variable blowfish_secret
RANDOM_VALUE=`openssl rand -hex 16`

# Modificamos la variable blowfish_secret en el archivo de configuración
sed -i "s/\(\$cfg\['blowfish_secret'\] =\).*/\1 '$RANDOM_VALUE';/" /var/www/html/phpmyadmin/config.inc.php


# Eliminar si existe alguna base de datos previa antes de importar la base de datos previa de phpmyadmin

mysql -u root <<< "DROP DATABASE IF EXISTS phpmyadmin"

# Importar el script de creacion de base de datos de phpmyadmin

mysql -u root < /var/www/html/phpmyadmin/sql/create_tables.sql

# Creación de usuario para la base de datos y asignación de privilegios:

mysql -u root <<< "DROP USER IF EXISTS $PMA_USER@'%'"
mysql -u root <<< "CREATE USER $PMA_USER@'%' IDENTIFIED BY '$PMA_PASS'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $PMA_DB.* TO $PMA_USER@'%'"


