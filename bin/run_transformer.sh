#!/usr/bin/env bash
set -a
source .env
set +a

${SPARK_HOME}/bin/spark-submit \
    --master "${SPARK_MASTER}" \
    --deploy-mode "${SPARK_DEPLOY_MODE}" \
    --conf "spark.executor.instances=1" \
    --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:2.4.3" \
    transformation/build/libs/transformation-1.0-SNAPSHOT-all.jar
