#!/bin/bash

domain=$1
root="/var/www/$domain/html"
block="/etc/nginx/sites-available/$domain"
logs="/var/www/$domain/logs"

# Create the Document Root directory
sudo mkdir -p $root

#Create the Logs directory
sudo mkdir -p $logs

# Assign ownership to your regular user account
sudo chown -R $USER:$USER $root
sudo chown -R $USER:$USER $logs

# Create the Nginx server block file:
sudo tee $block > /dev/null <<EOF
server {
        listen 80;
        root /var/www/$domain/html/;

        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;

        server_name $domain www.$domain;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ /index.php?\$args;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;

                # With php7.0-cgi alone:
                #fastcgi_pass 127.0.0.1:9000;
                # With php7.0-fpm:
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
                deny all;
        }

}


EOF

# Link to make it available
sudo ln -s $block /etc/nginx/sites-enabled/

# Test configuration and reload if successful
sudo nginx -t && sudo service nginx reload