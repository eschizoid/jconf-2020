#!/usr/bin/env bash
source .env

${SPARK_HOME}/bin/spark-submit \
    --master "${SPARK_MASTER}" \
    --deploy-mode "${SPARK_DEPLOY_MODE}" \
    --conf "spark.executor.memory=${SPARK_MEMORY}" \
    --conf "spark.driver.memory=${SPARK_MEMORY}" \
    --conf "spark.executor.instances=${SPARK_EXECUTOR_INSTANCES}" \
    --conf "spark.kubernetes.authenticate.driver.serviceAccountName=spark" \
    --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:python" \
    --conf "spark.kubernetes.driverEnv.AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
    --conf "spark.kubernetes.driverEnv.AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
    --conf "spark.kubernetes.driverEnv.BUCKET_NAME=${BUCKET_NAME}" \
    --conf "spark.kubernetes.driverEnv.CONSUMER_KEY=${CONSUMER_KEY}" \
    --conf "spark.kubernetes.driverEnv.CONSUMER_SECRET=${CONSUMER_SECRET}" \
    --conf "spark.kubernetes.driverEnv.LOGGING_LEVEL=${LOGGING_LEVEL}" \
    --conf "spark.kubernetes.driverEnv.SPARK_MASTER=${SPARK_MASTER}" \
    --conf "spark.kubernetes.driverEnv.TCP_IP=${TCP_IP}" \
    --conf "spark.kubernetes.driverEnv.TCP_PORT=${TCP_PORT}" \
    --conf "spark.kubernetes.pyspark.pythonVersion=3" \
    local:///opt/spark/examples/streaming/spark_consumer.py
