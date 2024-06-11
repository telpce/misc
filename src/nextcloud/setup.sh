# recreate
# docker compose down --rmi all --volumes --remove-orphans
# sudo rm -rf db
# sudo rm -rf config
# unlink data
# sudo rm -rf /mnt/d/nextcloud/data
#
mkdir /mnt/d/nextcloud/data
ln -s /mnt/d/nextcloud/data data
docker compose pull
docker compose up -d
#
# Please log in using your browser and proceed with the Nextcloud setup. If an error occurs during the process, execute the script below.
docker compose exec --user www-data --workdir /var/www/html/config app sed -i "/installed/a \  'check_data_directory_permissions' => false," config.php
docker compose restart
# complete