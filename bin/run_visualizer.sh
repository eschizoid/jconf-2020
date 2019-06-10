#!/usr/bin/env bash
set -a
source .env
set +a

node ./visualization/src/main/node/ChicagoCloudConference/index.js
