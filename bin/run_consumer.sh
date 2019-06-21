#!/usr/bin/env bash
set -a
source .env
set +a

export PYTHONPATH=$SPARK_HOME/python/:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip

if lsof -Pi :9009 -sTCP:LISTEN -t >/dev/null ; then
    ${SPARK_HOME}/bin/spark-submit \
        --master "${SPARK_MASTER}" \
        --deploy-mode "${SPARK_DEPLOY_MODE}" \
        --conf "spark.executor.instances=1" \
        --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:python" \
        --py-files "streaming/build/distributions/streaming-1.0-SNAPSHOT.tar.gz" \
        streaming/src/main/python/ChicagoCloudConference/spark_consumer.py
else
    echo "Socket not open. Start producer first!"
    exit 1
fi

