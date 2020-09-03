ARG base_img

FROM $base_img
WORKDIR /

# Reset to root to run installation tasks
USER 0

RUN mkdir ${SPARK_HOME}/R

RUN apt-get update && apt-get install -y --install-recommends gnupg2 dirmngr software-properties-common apt-transport-https &&\
  apt-get update

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' &&\
  add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian buster-cran35/' &&\
  apt-get update &&\
  apt install -y r-base &&\
  rm -rf /var/cache/apt/*

COPY R ${SPARK_HOME}/R
ENV R_HOME /usr/lib/R

WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Specify the User that the actual main process will run as
ARG spark_uid=185
USER ${spark_uid}
