#!/usr/bin/env bash
set -a
source .env
set +a

kubectl apply -f manifests/zeppelin.yaml

kubectl apply -f manifests/spark-rbac.yaml

AWS_ACCESS_KEY_ID="$(echo -n "${AWS_ACCESS_KEY_ID}" | base64)" \
AWS_SECRET_ACCESS_KEY="$(echo -n "${AWS_SECRET_ACCESS_KEY}" | base64)" \
BUCKET_NAME="$(echo -n "${BUCKET_NAME}" | base64)" \
CONSUMER_KEY="$(echo -n "${CONSUMER_KEY}" | base64)" \
CONSUMER_SECRET="$(echo -n "${CONSUMER_SECRET}" | base64)" \
ACCESS_TOKEN="$(echo -n "${ACCESS_TOKEN}" | base64)" \
ACCESS_SECRET="$(echo -n "${ACCESS_SECRET}" | base64)" \
SPARK_DEPLOY_MODE="$(echo -n "${SPARK_DEPLOY_MODE}" | base64)" \
SPARK_EXECUTOR_INSTANCES="$(echo -n "${SPARK_EXECUTOR_INSTANCES}" | base64)" \
SPARK_EXECUTOR_MEMORY="$(echo -n "${SPARK_EXECUTOR_MEMORY}" | base64)" \
SPARK_MASTER="$(echo -n "${SPARK_MASTER}" | base64)" \
TCP_IP="$(echo -n "${TCP_IP}" | base64)" \
TCP_PORT="$(echo -n "${TCP_PORT}" | base64)" \
envsubst < manifests/spark-secrets.yaml | kubectl apply -f -
