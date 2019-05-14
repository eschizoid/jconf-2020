#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

export PYTHONPATH=$SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip

PORT_OPEN="$(nmap -p ${TCP_PORT} ${TCP_IP} | grep "${TCP_PORT}" | grep open)"

if [[ -z "${PORT_OPEN}" ]]; then
  echo "Connection to ${TCP_IP} on port ${TCP_PORT} has failed"
  exit 1
else
  echo "Connection to ${TCP_IP} on port ${TCP_PORT} was successful"
  python3 ../python/spark_cosumer.py
fi
