# wordpress_installation
This is simple bash script for installing the wordpress in linux 

## Source code

```sh
#! /bin/bash
wp_package(){
pkgs="httpd mariadb mariadb-server php php-common php-mysql php-gd php-xml php-mbstring php-mcrypt"
for i in $pkgs;
do
        echo "Installing $i, please hold a momnent"
        yum install -y "$i"
done
echo "Starting the mysql process and httpd process"
        service httpd start
        service mariadb start
        systemctl enable mariadb
        systemctl enable httpd
w_data
}
w_data(){
echo -n "Please let me know how many wordpress website you would like to host: "
read count
for (( i=1; i<=$count; i++ ))
do
echo -n "Please enter the domain name you wish to use: "
read domain
echo -n "Please enter the database name you wish to use: "
read db
echo -n "Please enter the username you wish to use: "
read user
echo -n "Please enter the password name you wish to use: "
read -s "NOTE: The passsword will be hidden: " passwd
mysql -e "CREATE DATABASE ${db};"
echo "Databse created successfully"
mysql -e "CREATE USER ${user}@localhost IDENTIFIED BY '${passwd}';"
echo "User successfully created"

echo "Granting ALL prvilleges on ${db} to ${user}!"
mysql -e "GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "Downloding the wordpress file and please hold on"
curl -O https://wordpress.org/latest.zip
tar -xvzf latest.tar.gz -C /var/www/html
chown -R apache /var/www/html/wordpress/

cat > /etc/httpd/conf.d/$domain.conf << EOF
<VirtualHost *:80>
DocumentRoot /var/www/html/wordpress
ServerName $domain
ServerAlias $domain
</VirtualHost>
EOF
done
w_restart
}
w_restart(){
service httpd restart
}
w_main(){
        wp_package
}
w_main
exit
```
