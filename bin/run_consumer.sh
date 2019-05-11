#!/usr/bin/env bash
set -a
source .env
set +a

export PYTHONPATH=$SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip

if lsof -Pi :9009 -sTCP:LISTEN -t >/dev/null ; then
    python3 ./streaming/src/main/python/ChicagoCloudConference/spark_cosumer.py
else
    echo "Socket not open. Start consumer first!"
    exit 1
fi

