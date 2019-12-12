COMPOSE_ARGS=" -f jenkins.yml -p jenkins"

sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

sudo docker-compose $COMPOSE_AGRS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

sudo docker ps

sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?

if [ $ERR -eq0 ]; then
	IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1)
	CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true

	if [ $CODE -eq 200 ]; then
		echo "Test passed - Tagging"
		HASH=$(git rev-parse --short HEAD)
		sudo docker tag -f jenkins_identidock vsharenda/identidock:$HASH
		sudo docker tag -f jenkins_identidock vsharenda/identidock:newest
		echo "Pushing"
		sudo docker login -e vsharenda@gmail.com -u vsharenda -p ZG9ja2VyLmNvbQ
		sudo docker push vsharenda/identidock:$HASH
		sudo docker push vsharenda/identidock:newest
	else
		echo "site returned" $CODE
		ERR=1
	fi
fi

sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $ERR