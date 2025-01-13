@echo off
echo Stopping the Elastic stack...
docker-compose -f docker-compose.yml down

echo Removing elastic network...
docker network rm elastic

echo Cleanup complete!
