#!/usr/bin/env bash
set -a
source .env
set +a

#kubectl apply -f manifests/zeppelin.yaml

kubectl create serviceaccount spark

kubectl create clusterrolebinding spark-role \
    --clusterrole=edit \
    --serviceaccount=default:spark \
    --namespace=default
