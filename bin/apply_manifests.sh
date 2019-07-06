#!/usr/bin/env bash
set -a
source .env
set +a

#kubectl apply -f manifests/zeppelin.yaml

# Required for K8S Dashboard
kubectl create clusterrolebinding kube-system-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:default

# Required for Spark
kubectl create serviceaccount spark

kubectl create clusterrolebinding spark-role \
    --clusterrole=edit \
    --serviceaccount=default:spark \
    --namespace=default
