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
            ${SPARK_SUBMIT_BIN}/bin/spark-submit \
                --master "${SPARK_MASTER}" \
                --deploy-mode ${SPARK_DEPLOY_MODE} \
                --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:python" \
                --conf "spark.kubernetes.authenticate.driver.serviceAccountName=spark" \
                --conf "spark.kubernetes.driverEnv.AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
                --conf "spark.kubernetes.driverEnv.AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
                --conf "spark.kubernetes.driverEnv.BUCKET_NAME=${BUCKET_NAME}" \
                --conf "spark.kubernetes.driverEnv.CONSUMER_KEY=${CONSUMER_KEY}" \
                --conf "spark.kubernetes.driverEnv.CONSUMER_SECRET=${CONSUMER_SECRET}" \
                --conf "spark.kubernetes.driverEnv.JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk" \
                --conf "spark.kubernetes.driverEnv.LOGGING_LEVEL=${LOGGING_LEVEL}" \
                --conf "spark.kubernetes.driverEnv.SPARK_MASTER=${SPARK_MASTER}" \
                --conf "spark.kubernetes.driverEnv.TCP_IP=${TCP_IP}" \
                --conf "spark.kubernetes.driverEnv.TCP_PORT=${TCP_PORT}" \
                --conf "spark.kubernetes.pyspark.pythonVersion=3" \
                --py-files "local:///opt/spark//streaming/streaming-1.0-SNAPSHOT.tar.gz" \
                local:///opt/spark/examples/streaming/twitter_producer.py --track ${track}
            ;;
        \?)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
fi
