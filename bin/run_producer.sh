#!/usr/bin/env bash
set -a
source .env
set +a

python3 ./streaming/src/main/python//ChicagoCloudConference/twitter_producer.py
