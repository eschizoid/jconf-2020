#!/usr/bin/env bash

echo "Building spark 3.0.0 image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  build

echo "Building spark python image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  -p /opt/spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile \
  build

echo "Building spark R image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  -R  /opt/spark/kubernetes/dockerfiles/spark/bindings/R/Dockerfile \
  build

echo "Building zeppelin image"
cd infrastructure/zeppelin || exit
docker build \
  -t eschizoid/zeppelin:0.9.0-preview1 .
