#! /bin/bash
wp_package(){
amazon-linux-extras enable php7.4
yum install php php-common php-pear
pkgs="httpd mariadb mariadb-server php-gd php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip}"
for i in $pkgs;
do
        echo "Installing $i, please hold a momnent"
        yum install -y "$i"
done
echo ""
echo "Starting the mysql process and httpd process"
echo ""
        service httpd start
        service mariadb start
        systemctl enable mariadb
        systemctl enable httpd
w_data
}
w_data(){
echo ""
echo -n "Please let me know how many wordpress website you would like to host: "
read count
for (( i=1; i<=$count; i++ ))
do
echo ""
echo -n "Please enter the $i domain name you wish to use: "
read domain
echo ""
echo  "Please enter the database name you wish to use: "
read -p "Please don't use the test databse since it's already available on the server: " db
echo ""
echo -n "Please enter the username you wish to use: "
read user
echo ""
echo -n "Please enter the password name you wish to use: "
read passwd


## Mysql database creating section here

mysql -e "CREATE DATABASE ${db};"
echo "Databse created successfully"
mysql -e "CREATE USER ${user}@localhost IDENTIFIED BY '${passwd}';"
echo "User successfully created"

echo "Granting ALL prvilleges on ${db} to ${user}!"
mysql -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

## Downloading the wordpress file here

echo ""
echo "Downloding the wordpress file and please hold on"
echo ""
curl -O https://wordpress.org/latest.tar.gz
mkdir /var/www/html/$domain
tar -xvzf latest.tar.gz
rsync -avzhu wordpress/* /var/www/html/$domain/
chown -R apache.apache /var/www/html/$domain/
cp -a /var/www/html/$domain/wp-config-sample.php /var/www/html/$domain/wp-config.php
sed -i "s/database_name_here/$db/g" /var/www/html/$domain/wp-config.php
sed -i "s/username_here/$user/g" /var/www/html/$domain/wp-config.php
sed -i "s/password_here/$passwd/g" /var/www/html/$domain/wp-config.php

cat > /etc/httpd/conf.d/$domain.conf << EOF
<VirtualHost *:80>
DocumentRoot /var/www/html/$domain/
ServerName $domain
ServerAlias $domain
</VirtualHost>
EOF
wp_information
done
w_restart
}
w_restart(){
service httpd restart
rm -rf latest.tar.gz wordpress
}
wp_information(){
echo "Please check the following information about your wordpress site"
echo ""
echo "The $i domain is $domain and the wordpress admin is http://$domain/wp-admin"
echo ""
echo "The databse you have entered was $db"
echo ""
echo "The database username you have entered was $user"
echo ""
echo "The password you have entered was $passwd"
echo ""
echo "Thank you for using myscript and enjoy : ) "
}
w_main(){
        wp_package
}
w_main
exit
