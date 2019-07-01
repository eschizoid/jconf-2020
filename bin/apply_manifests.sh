#!/usr/bin/env bash
set -a
source .env
set +a

kubectl apply -f manifests/zeppelin.yaml
kubectl apply -f manifests/spark-rbac.yaml
envsubst < manifests/spark-secrets.yaml | kubectl apply -f -
