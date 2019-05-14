#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export CONSUMER_KEY=${CONSUMER_KEY}
export CONSUMER_SECRET=${CONSUMER_SECRET}
export ACCESS_TOKEN=${ACCESS_TOKEN}
export ACCESS_SECRET=${ACCESS_SECRET}
export TCP_IP=${TCP_IP}
export TCP_PORT=${TCP_PORT}

python3 ./streaming/src/main/python/twitter_producer.py
