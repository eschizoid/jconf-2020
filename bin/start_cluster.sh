#!/usr/bin/env bash

set -a
source .env
set +a

eksctl create cluster \
  --name=jconf-2020 \
  --nodes=5 \
  --version=1.17 \
  --region=us-east-1 \
  --node-type t3.xlarge \
  --zones=us-east-1a,us-east-1b,us-east-1d
