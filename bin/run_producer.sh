#!/usr/bin/env bash
set -a
source .env
set +a

CONSUMER_KEY="${CONSUMER_KEY}" \
CONSUMER_SECRET="${CONSUMER_SECRET}" \
ACCESS_TOKEN="${ACCESS_TOKEN}" \
ACCESS_SECRET="${ACCESS_SECRET}" \
LOGGING_LEVEL="${LOGGING_LEVEL}" \
envsubst < manifests/twitter_producer.yaml | kubectl apply -f -
