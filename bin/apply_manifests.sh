#!/usr/bin/env bash
set -a
source .env
set +a

# K8S Dashboard
kubectl create clusterrolebinding kube-system-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=kube-system:default

# Spark Permissions
kubectl create serviceaccount spark

kubectl create clusterrolebinding spark-role \
    --clusterrole=edit \
    --serviceaccount=default:spark \
    --namespace=default
