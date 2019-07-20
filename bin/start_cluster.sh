#!/usr/bin/env bash

set -a
source .env
set +a

eksctl create cluster \
    --name=chicago-cloud-conference-2019 \
    --nodes=5 \
    --version=1.12 \
    --region=us-east-1 \
    --node-type t3.xlarge \
    --zones=us-east-1a,us-east-1b,us-east-1d
