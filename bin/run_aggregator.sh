#!/usr/bin/env bash
set -a
source .env
set +a

R --slave < $(pwd)/aggregation/src/main/R/ChicagoCloudConference/aggregator.R

#${SPARK_HOME}/bin/spark-submit \
#    --master "${SPARK_MASTER}" \
#    --deploy-mode "${SPARK_DEPLOY_MODE}" \
#    --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:R"
