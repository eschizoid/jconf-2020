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
                --deploy-mode "${SPARK_DEPLOY_MODE}" \
                --conf "spark.executor.cores=1" \
                --conf "spark.executor.instances=${SPARK_EXECUTOR_INSTANCES}" \
                --conf "spark.executor.memory=${SPARK_EXECUTOR_MEMORY}" \
                --conf "spark.kubernetes.container.image=docker.io/eschizoid/spark:python" \
                --conf "spark.kubernetes.authenticate.driver.serviceAccountName=default" \
                --conf "spark.kubernetes.driver.secrets.chicago-cloud-conference-secrets=/etc/secrets" \
                --conf "spark.kubernetes.driver.secretKeyRef.AWS_ACCESS_KEY_ID=chicago-cloud-conference-secrets:aws_access_key_id" \
                --conf "spark.kubernetes.driver.secretKeyRef.AWS_SECRET_ACCESS_KEY=chicago-cloud-conference-secrets:aws_secret_access_key" \
                --conf "spark.kubernetes.driver.secretKeyRef.BUCKET_NAME=chicago-cloud-conference-secrets:bucket_name" \
                --conf "spark.kubernetes.driver.secretKeyRef.CONSUMER_KEY=chicago-cloud-conference-secrets:consumer_key" \
                --conf "spark.kubernetes.driver.secretKeyRef.CONSUMER_SECRET=chicago-cloud-conference-secrets:consumer_secret" \
                --conf "spark.kubernetes.driver.secretKeyRef.SPARK_DEPLOY_MODE=chicago-cloud-conference-secrets:spark_deploy_mode" \
                --conf "spark.kubernetes.driver.secretKeyRef.SPARK_MASTER=chicago-cloud-conference-secrets:spark_master" \
                --conf "spark.kubernetes.driver.secretKeyRef.TCP_IP=chicago-cloud-conference-secrets:tcp_ip" \
                --conf "spark.kubernetes.driver.secretKeyRef.TCP_PORT=chicago-cloud-conference-secrets:tcp_port" \
                --conf "spark.kubernetes.executor.secrets.chicago-cloud-conference-secrets=/etc/secrets" \
                --conf "spark.kubernetes.executor.secretKeyRef.AWS_ACCESS_KEY_ID=chicago-cloud-conference-secrets:aws_access_key_id" \
                --conf "spark.kubernetes.executor.secretKeyRef.AWS_SECRET_ACCESS_KEY=chicago-cloud-conference-secrets:aws_secret_access_key" \
                --conf "spark.kubernetes.executor.secretKeyRef.BUCKET_NAME=chicago-cloud-conference-secrets:bucket_name" \
                --conf "spark.kubernetes.executor.secretKeyRef.CONSUMER_KEY=chicago-cloud-conference-secrets:consumer_key" \
                --conf "spark.kubernetes.executor.secretKeyRef.CONSUMER_SECRET=chicago-cloud-conference-secrets:consumer_secret" \
                --conf "spark.kubernetes.executor.secretKeyRef.SPARK_DEPLOY_MODE=chicago-cloud-conference-secrets:spark_deploy_mode" \
                --conf "spark.kubernetes.executor.secretKeyRef.SPARK_MASTER=chicago-cloud-conference-secrets:spark_master" \
                --conf "spark.kubernetes.executor.secretKeyRef.TCP_IP=chicago-cloud-conference-secrets:tcp_ip" \
                --conf "spark.kubernetes.executor.secretKeyRef.TCP_PORT=chicago-cloud-conference-secrets:tcp_port" \
                --conf "spark.kubernetes.pyspark.pythonVersion=3" \
                --py-files "${SPARK_HOME}/examples/streaming/build/distributions/streaming-1.0-SNAPSHOT.tar.gz" \
                local://${SPARK_HOME}/examples/streaming/twitter_producer.py --track ${track}
            ;;
        \?)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
fi
