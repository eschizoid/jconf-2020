#!/usr/bin/env bash

echo "Pushing spark 3.0.0 base image"
docker push eschizoid/spark:3.0.0

echo "Pushing spark 3.0.0 python image"
docker push eschizoid/spark-py:3.0.0

echo "Pushing spark 3.0.0 R image"
docker push eschizoid/spark-r:3.0.0

echo "Pushing Zeppelin 0.9.0 preview1"
docker push eschizoid/zeppelin:0.9.0-preview1
