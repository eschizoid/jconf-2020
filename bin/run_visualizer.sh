#!/usr/bin/env bash
set -a
source .env
set +a

# Zeppelin
kubectl apply -f manifests/zeppelin.yaml
