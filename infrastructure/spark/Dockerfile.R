FROM eschizoid/spark:2.4.3
WORKDIR /
RUN mkdir /opt/spark/R

RUN apk add --no-cache R R-dev

COPY dist/R /opt/spark/R
ENV R_HOME /usr/lib/R

WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]
