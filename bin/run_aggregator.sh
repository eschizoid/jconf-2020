#!/usr/bin/env bash
set -a
source .env
set +a

R --slave < $(pwd)/aggregation/src/main/R/ChicagoCloudConference/aggregator.R
