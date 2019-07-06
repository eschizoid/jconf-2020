#!/usr/bin/env bash

cd streaming

pip3 install \
    -t dependencies \
    -r pinned.txt

zip -r dependencies.zip dependencies
