#!/usr/bin/env bash

if command -v python3.7 >/dev/null; then
    export PYTHON_BIN="$(which python3.7)"
else
    echo "python3.7 is not installed"
    exit -1
fi

if command -v R >/dev/null; then
    export R_BIN="$(which R)"
else
    echo "R is not installed"
    exit -1
fi

./gradlew build rPackageDest rPackageBuild
