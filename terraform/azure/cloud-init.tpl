#cloud-config
package_update: true
package_upgrade: true

packages:
  - nginx
  - php-fpm
  - php-cli
  - php-common
  - php-curl
  - php-gd
  - php-mbstring
  - php-xml
  - php-zip
  - php-intl
  - php-mysql
  - unzip
  - git

write_files:
  - path: /etc/nginx/sites-available/app.conf
    content: |
      server {
          listen 80;
          listen [::]:80;

          server_name ${server_name};

          root /var/www/app/public;
          index index.php index.html index.htm;

          access_log /var/log/nginx/app_access.log;
          error_log  /var/log/nginx/app_error.log;

          location / {
              try_files $uri /index.php?$query_string;
          }

          location ~ \.php$ {
              include snippets/fastcgi-php.conf;
              # Ubuntu 22.04 default PHP-FPM socket
              fastcgi_pass unix:/run/php/php8.1-fpm.sock;
          }

          location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|tiff)$ {
              expires 30d;
              access_log off;
          }

          client_max_body_size 64M;
      }
    permissions: "0644"

  - path: /var/www/app/public/index.php
    content: |
      <?php
      header('Content-Type: text/plain');
      echo "Nginx + PHP-FPM is up.\n";
      echo "Server: ${server_name}\n";
    permissions: "0644"

runcmd:
  - systemctl enable nginx
  - systemctl enable php*-fpm
  - rm -f /etc/nginx/sites-enabled/default
  - ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf
  - systemctl restart php*-fpm
  - systemctl restart nginx