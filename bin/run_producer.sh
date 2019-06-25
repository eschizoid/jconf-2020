#!/usr/bin/env bash
set -a
source .env
set +a

usage() { echo "Usage: $0 [-t]" 1>&2; exit 1; }

if [[ $1 == "" ]]; then
    usage;
    exit -1
else
   while getopts "t:" o; do
    case "${o}" in
        t)
            track=${OPTARG}
            ${SPARK_HOME}/bin/spark-submit \
                --master "${SPARK_MASTER}" \
                --deploy-mode "${SPARK_DEPLOY_MODE}" \
                --conf "spark.executor.instances=1" \
                --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:python" \
                --py-files "streaming/build/distributions/streaming-1.0-SNAPSHOT.tar.gz" \
                streaming/src/main/python/ChicagoCloudConference/twitter_producer.py --track ${track}
            ;;
        \?)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
fi
