#!/bin/bash

#Create Network
docker network create trio-task-network

#Build images
docker build -t trio-db db
docker build -t trio-flask-app flask-app

#Run database Container
docker run -d \
    --network trio-task-network \
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