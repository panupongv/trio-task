#!/bin/bash

echo "Stopping All Containers..."
docker stop $(docker ps -a --format "{{.ID}}") || exit 0
echo "Removing All Containers..."
docker rm $(docker ps -a --format "{{.ID}}") || exit 0
echo "Removing all Images..."
docker rmi $(docker images --format "{{.ID}}") || exit 0

#Create Network
docker network create trio-task-network

#Create Volume
docker volume create trio-db-volume 

#Build images
docker build -t trio-db db
docker build -t trio-flask-app flask-app

#Run database Container
docker run -d \
    --network trio-task-network \
    --volume trio-db-volume:/var/lib/mysql \
    --name mysql \
    trio-db

#Run flask app container
docker run -d \
    --network trio-task-network \
    --name flask-app \
    trio-flask-app

#Run nginx container
docker run -d \
    --network trio-task-network \
    --mount type=bind,source=$(pwd)/nginx/nginx.conf,target=/etc/nginx/nginx.conf \
    -p 80:80 \
    --name nginx \
    nginx:alpine