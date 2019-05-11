#!/usr/bin/env bash

echo "Building spark base image"
docker build -t spark:base -f dist/kubernetes/dockerfiles/spark/Dockerfile .

echo "Building spark python image"
docker build -t spark:python -f dist/kubernetes/dockerfiles/spark/bindings/python/Dockerfile .

echo "Building spark R image"
docker build -t spark:R -f dist/kubernetes/dockerfiles/spark/bindings/R/Dockerfile .
