FROM openjdk:8-alpine

ARG spark_dist=dist
ARG spark_bin=${spark_dist}/bin
ARG spark_examples=${spark_dist}/examples
ARG spark_data=${spark_dist}/data
ARG spark_jars=${spark_dist}/jars
ARG spark_sbin=${spark_dist}/sbin
ARG img_path=${spark_dist}/kubernetes/dockerfiles
ARG k8s_tests=${spark_dist}/kubernetes/tests

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:2.4.3 -f Dockerfile
# docker build -t spark:python -f Dockerfile.python
# docker build -t spark:R -f Dockerfile.R

# hadolint ignore=DL3017,DL3018,DL4005
RUN set -ex && \
    apk upgrade --no-cache && \
    apk add --no-cache bash tini libc6-compat linux-pam nss && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

COPY ${spark_jars} /opt/spark/jars
COPY ${spark_bin} /opt/spark/bin
COPY ${spark_sbin} /opt/spark/sbin
COPY ${img_path}/spark/entrypoint.sh /opt/
COPY ${spark_examples} /opt/spark/examples
COPY ${k8s_tests} /opt/spark/tests
COPY ${spark_data} /opt/spark/data

ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar /opt/spark/jars/aws-java-sdk-1.7.4.jar
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar /opt/spark/jars/hadoop-aws-2.7.3.jar
ADD https://repo1.maven.org/maven2/io/minio/spark-select_2.11/2.0/spark-select_2.11-2.0.jar /opt/spark/jars/spark-select_2.11-2.0.jar

ENV SPARK_HOME /opt/spark

WORKDIR /opt/spark/work-dir

ENTRYPOINT [ "/opt/entrypoint.sh" ]
