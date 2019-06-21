#!/usr/bin/env bash

cd infrastructure/spark

echo "Building spark 2.4.3 image"
docker build -t spark:2.4.3 -f Dockerfile .

echo "Building spark python image"
docker build -t spark:python -f Dockerfile.python .

echo "Building spark R image"
docker build -t spark:R -f Dockerfile.R .

cd ../zeppelin

echo "Building zeppelin image"
docker build -t zeppelin:0.9.0-SNAPSHOT .
