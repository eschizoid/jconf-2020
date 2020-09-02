#!/usr/bin/env bash

echo "Building spark 3.0.0 image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  -b java_image_tag=11-jre-slim \
  build

echo "Building spark python image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  -b java_image_tag=11-jre-slim \
  -p /opt/spark/kubernetes/dockerfiles/spark/bindings/python/Dockerfile \
  build

echo "Building spark R image"
/opt/spark/bin/docker-image-tool.sh \
  -r docker.io/eschizoid \
  -t 3.0.0 \
  -b java_image_tag=11-jre-slim \
  -R  /opt/spark/kubernetes/dockerfiles/spark/bindings/R/Dockerfile \
  build

#cd ../zeppelin || exit

#echo "Building zeppelin image"
#docker build --no-cache \
#    -t eschizoid/zeppelin:0.9.0-preview1 .
