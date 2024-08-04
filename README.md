### L A M P  en RHEL

Para la realización de esta práctica se lanzará un nueva instancia en este caso de **RedHat** donde se hará la instalación de la pila en **RHEL**. Por ello el gestor de paquetes usado no será **apt** si no **dnf**.

## 1. Inicial:

Primeramente empezaré configurando dentro de la una carpeta llamada *Scripts*, 2 archivos **.sh** el primero será donde se realizará lo que concierne a la instalación de la pila **LAMP** (install_lamp.sh) y el segundo para el agregado de ciertas *tools* (installtools.sh).

![](images/ScriptsCarpeta.png)

### 1.1 Configuraciones iniciales:

Desde el script de *install_lamp.sh* es donde se realizarán las configuraciones iniciales, a continuación se muestra el siguiente comando para que vaya mostrando los comandos que se ejecutan:

#### Mostrar comandos:

```
set -x
```
#### Actualización de paquetes y repositorios:

Con el siguiente comando podemos realizar la actualización de la lista de paquetes:

```
dnf update -y
```

## 2. Implantación de la pila:

### 2.1 Instalación de APACHE:

Para la distribución de **RedHat** el **Apache** tiene el nombre de **httpd** para dicho servidor web.

Con el siguiente comando se realiza la instalación del servidor web:

```
dnf install httpd -y
```

Para poder iniciar el servicio de apache se puede hacer mediante el siguiete comando:

```
systemctl start httpd
```
Después de la inicialización se pasaría a emplear el siguiente comando para que el servicio se inicie de forma automática:

```
systemctl enable httpd
```

### 2.2 Instalación de MySQL:

Empleando este comando pasaré con la instalación de MySQL, y el parámetro **-y** es para que no salga la pregunta de confirmación:

```
dnf install mysql-server -y
```

Después pasaría a **inciar** el **MySQL** con el siguiente comando:

```
systemctl start mysqld
```

Luego para que el servicio se inicie de forma automática empleo el siguiente comando:

```
systemctl enable mysqld
```
### 2.3 Instalación de PHP:

Empleando este comando pasaré con la instalación de **PHP**, y el parámetro **-y** es para que no salga la pregunta de confirmación:

```
dnf install php -y
```

Para el conexionado con la base de datos se puede emplear el siguiente comando:

```
dnf install php-mysqlnd -y
```

Para que los cambios se apliquen será necesario que se reinicie el servicio de **Apache**:

```
systemctl restart httpd
```
### 3. Herramientas adicionales

Esta parte de la práctica se realizará desde el otro script *install_tools.sh*. En el que nos traeremos ciertos modulos **PHP** necesarios para el **phpmyadmin** asi como también descargar el codigo fuente de phpmyadmin por el metodo de descarga (no de GitHub).

Dentro de la carpeta de *scripts* esta implementado un archivo **.env** donde se ponen las variables necesarias para posteriormente la creación de los usuarios de **MySQL** **usuario**, **contraseña** y la **base de datos**.


![](images/variables.png)

En esta parte de aquí estoy empezando con la instalación de ciertos módulos de **PHP** necesarios para **phpmyadmin**:

```
dnf install php-mbstring php-zip php-json php-gd php-fpm php-xml -y
```
Después de lo anterior se puede pasar a la reiniciación del servicio de apache:

```
systemctl restart httpd
```

### 3.1 Instalación de wget

Con este comando se realiza la instalación de la herramienta:

```
dnf install wget -y
```
Antes de nada pasamos con la **eliminación de descargas previas** del **phpmyadmin**:

```
rm -rf /tmp/phpMyAdmin-5.2.1-all-languages.zip
```
También de la propia **ruta** donde se aloja el **phpmyadmin** se eliminan instalaciones previas:

```
rm -rf /var/www/html/phpmyadmin
```
### 3.2 Código fuente del phpmyadmin

Con el siguiente comando se puede descargar el código fuente del phpmyadmin y con el parámetro **-P** para redireccionar el resultado a la **carpeta temporal**:
```
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip -P /tmp
```

Para descomprimirlo se realizará la instalación de **unzip**:

```
dnf install unzip -y
```

Seguidamente se puede pasar con la descompresión del archivo **.zip**:

```
unzip -u /tmp/phpMyAdmin-5.2.1-all-languages.zip -d /var/www/html
```
Para darle un **nombre más personalizado** a la hora de acceder al **phpmyadmin** via **navegador** lo **renombreremos**:

```
mv /var/www/html/phpMyAdmin-5.2.1-all-languages /var/www/html/phpmyadmin
```
Justo despues se puede pasar a cambiar el **propietario** y **grupo** por el de apache:

```
chown -R apache:apache /var/www/html
```
### 3.3 Construcción de la base de datos con el código fuente del phpmyadmin

Realizamos el copiado de **config.sample.inc.php** en **config.inc.php** en la ruta **/var/www/html/phpmyadmin** para realizar la construcción de la **base de datos** en el codigo fuente de **phpmyadmin**

```
cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
```
### 3.4 Generación de valor aleatorio de 32 caracteres

`Primer warning de las cookies:`

Con esta variable de aquí me generaremos el valor aleatorio cifrado que luego mediante la expresión regular se implmentará en el archivo
**config.inc.php**, esto será útil para solventar el **warning de las cookies** de phpmyadmin:

```
RANDOM_VALUE=`openssl rand -hex 16`
```
Con la expresión **s/** para buscar/reemplazar, y lo que hace es buscar la cadena
**$cfg['blowfish_secret'] =** y mediante **/1** se le indica que una el valor generado de la variable **$RANDOM_VALUE**, y se redirige al archivo de configuración:
```
sed -i "s/\(\$cfg\['blowfish_secret'\] =\).*/\1 '$RANDOM_VALUE';/" /var/www/html/phpmyadmin/config.inc.php
```
`Segundo warning del /tmp:`

La siguiente expresión regular estaría indicando que la cadena **$cfg['TempDir'] = '/tmp'** me la ponga una linea por debajo de la cadena **blowfish_secret** con el parametro **a**, en el archivo de configuración **config.inc.php**:

```
 sed -i "/blowfish_secret/a \$cfg\['TempDir'\] = '/tmp';" /var/www/html/phpmyadmin/config.inc.php 
 ```
 ### 3.5 Configuración de los usuarios de MySQL:

 Habrá que elimianr eliminar si existe alguna base de datos previa antes de importar la base de datos previa de phpmyadmin para que no genere conflicto:

```
mysql -u root <<< "DROP DATABASE IF EXISTS phpmyadmin"
```
Importar el script de creacion de base de datos de phpmyadmin:

```
mysql -u root < /var/www/html/phpmyadmin/sql/create_tables.sql
```

Despues de haber realizado lo anterior se puede pasar con la **creación del usuario** de **MySQL** y la base de datos llamando a las **variables** que inicialmente mostré, se indicará que borre el usuario si existe ya que si no existe no te lo crea:

```
mysql -u root <<< "DROP USER IF EXISTS $PMA_USER@'%'"
----------------------------------------------
mysql -u root <<< "CREATE USER $PMA_USER@'%' IDENTIFIED BY '$PMA_PASS'"
----------------------------------------------
mysql -u root <<< "GRANT ALL PRIVILEGES ON $PMA_DB.* TO $PMA_USER@'%'"
```
