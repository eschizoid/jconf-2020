#!/usr/bin/env bash
set -a
source .env
set +a

usage() { echo "Usage: $0 [-t]" 1>&2; exit 1; }

while getopts "t:" o; do
    case "${o}" in
        t)
            track=${OPTARG}
            python3 ./streaming/src/main/python/ChicagoCloudConference/twitter_producer.py --track ${track}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
