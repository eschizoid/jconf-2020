#!/usr/bin/env bash

cd infrastructure/spark || exit

echo "Building spark 2.4.3 image"
docker build --no-cache \
    -t spark:2.4.3 -f Dockerfile .

echo "Building spark python image"
docker build --no-cache \
    -t spark:python -f Dockerfile.python .

echo "Building spark R image"
docker build --no-cache \
    -t spark:R -f Dockerfile.R .

cd ../zeppelin || exit

echo "Building zeppelin image"
docker build --no-cache \
    -t zeppelin:0.9.0-SNAPSHOT .
