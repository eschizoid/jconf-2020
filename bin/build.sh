#!/usr/bin/env bash

if command -v python3.7 >/dev/null; then
    export PYTHON_BIN="$(which python3.7)"
    ./gradlew clean build rPackageBuild
else
    echo "python3.7 is not installed"
    exit -1
fi
