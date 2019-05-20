#!/usr/bin/env bash
set -a
source .env
set +a

while getopts ":track:" opt; do
  case ${opt} in
    track )
      python3 ./streaming/src/main/python/ChicagoCloudConference/twitter_producer.py --track ${OPTARG}
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))
