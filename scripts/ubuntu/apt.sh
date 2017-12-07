#!/bin/bash

set -e
set -x

# In Ubuntu 12.04, the contents of /var/lib/apt/lists are corrupt
ubuntu_version=$(lsb_release -r | awk '{ print $2 }')
if [ "$ubuntu_version" == '12.04' ]; then
  sudo rm -rf /var/lib/apt/lists
fi

sudo apt-get update && sudo apt-get -y upgrade 

sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password jym4Ayl'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password jym4Ayl'

sudo apt-get install -y mysql-server mysql-client

mysql --user=root --password=jym4Ayl -e "CREATE DATABASE wordpress;"

mysql --user=root --password=jym4Ayl -e "CREATE USER wordpressuser@localhost IDENTIFIED BY 'password';"

mysql --user=root --password=jym4Ayl -e "GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost;"

mysql --user=root --password=jym4Ayl -e "FLUSH PRIVILEGES;"

sudo apt-get install -y php7.0-fpm php7.0-mysql php7.0-gd php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-zip libssh2-1

sleep 10s
sudo cp  /etc/php/7.0/fpm/php.ini  /etc/php/7.0/fpm/php.ini.orig

sudo cp  /etc/php/7.0/fpm/pool.d/www.conf  /etc/php/7.0/fpm/pool.d/www.conf.orig

sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/'  /etc/php/7.0/fpm/php.ini

sudo sed -i 's|listen = /run/php/php7.0-fpm.sock|listen =127.0.0.1:9000|g' /etc/php/7.0/fpm/pool.d/www.conf

sudo apt-get install -y nginx

sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sleep 10s
#create file default in nginx directory
#sudo touch /etc/nginx/sites-available/default

sudo echo "server {" > /tmp/default
sudo echo "listen 80;" >> /tmp/default
sudo echo "root /var/www/wordpress;" >> /tmp/default
sudo echo "index index.php index.php index.html index.htm;" >> /tmp/default
sudo echo "server_name localhost;" >> /tmp/default
sudo echo "location / {" >> /tmp/default
sudo echo "try_files "'$'"uri "'$'"uri/ /index.php?q="$"uri&"'$'"args;" >> /tmp/default
sudo echo "}" >> /tmp/default
sudo echo "error_page 404 /404.html;" >> /tmp/default
sudo echo "error_page 500 502 503 504 /50x.html;" >> /tmp/default
sudo echo "location = /50x.html {" >> /tmp/default
sudo echo "root /usr/share/nginx/html;" >> /tmp/default
sudo echo "}" >> /tmp/default
sudo echo "location ~ "'\.'"php$ {" >> /tmp/default
sudo echo "try_files "'$'"uri =404;" >> /tmp/default
sudo echo "fastcgi_split_path_info ^(.+"'\.'"php)(/.+)$;" >> /tmp/default
sudo echo "fastcgi_param SCRIPT_FILENAME "'$'"document_root"'$'"fastcgi_script_name;" >> /tmp/default
sudo echo "fastcgi_pass 127.0.0.1:9000;" >> /tmp/default
sudo echo "fastcgi_index index.php;" >> /tmp/default
sudo echo "include fastcgi_params;" >> /tmp/default
sudo echo "}" >> /tmp/default
sudo echo "}" >> /tmp/default

sudo cp /tmp/default /etc/nginx/sites-available/

sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/wordpress

sudo echo -----------------------------------------------------------------------
sudo wget http://wordpress.org/latest.tar.gz -q -P /tmp

sudo tar xzfC /tmp/latest.tar.gz /tmp

sudo  rm /tmp/latest.tar.gz

sudo cp /tmp/wordpress/wp-config-sample.php  /tmp/wordpress/wp-config.php

#SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)

#STRING='put your unique phrase here'

#sudo printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /tmp/wordpress/wp-config.php

sudo sed -i "s/database_name_here/wordpress/"  /tmp/wordpress/wp-config.php

sudo sed -i "s/username_here/wordpressuser/"       /tmp/wordpress/wp-config.php

sudo sed -i "s/password_here/password/"   /tmp/wordpress/wp-config.php

sudo sed -i "s/wp_/wnotp_/"               /tmp/wordpress/wp-config.php

sudo cp -R /tmp/wordpress /var/www

sudo chown -R www-data:www-data /var/www

sudo rm -r /tmp/wordpress

# Setup file and directory permissions on Wordpress

sudo chmod -R 755 /var/www/wordpress

sudo service nginx reload

sudo service nginx restart

sudo service php7.0-fpm reload

sudo service php7.0-fpm restart

