#!/usr/bin/env bash

rm -rf pivy-importer-0.9.9-all.jar

wget https://dl.bintray.com/linkedin/maven/com/linkedin/pygradle/pivy-importer/0.9.9/pivy-importer-0.9.9-all.jar

mkdir repo

java -jar pivy-importer-0.9.9-all.jar \
    --repo /tmp/repo twython:3.7.0 pyspark:2.4.3
