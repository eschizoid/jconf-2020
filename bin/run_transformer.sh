#!/usr/bin/env bash
set -a
source .env
set +a

java -jar ./transformation/build/libs/transformation-1.0-SNAPSHOT-all.jar
