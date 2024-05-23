docker compose exec -u www-data app php occ maintenance:mode --on
sleep 60
docker compose down
docker compose pull
docker compose up -d
sleep 60
docker compose exec -u www-data app php occ maintenance:mode --off
