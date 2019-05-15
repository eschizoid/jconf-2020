#!/usr/bin/env bash

docker build -t spark:base -f infrastructure/dist/kubernetes/dockerfiles/spark//Dockerfile .
docker build -t spark:R -f infrastructure/dist/kubernetes/dockerfiles/spark/bindings/R/Dockerfile .
docker build -t spark:python -f infrastructure/dist/kubernetes/dockerfiles/spark/bindings/python/Dockerfile .
