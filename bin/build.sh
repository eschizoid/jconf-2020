#!/usr/bin/env bash
set -a
source .env.local
set +a

if command -v java >/dev/null; then
    echo "java runtime found"
else
    echo "java is not installed"
    exit -1
fi

if command -v python3.7 >/dev/null; then
    echo "python3.7 runtime found"
    export PYTHON_BIN="$(which python3.7)"
else
    echo "python3.7 runtime not found"
    exit -1
fi

if command -v node >/dev/null; then
    echo "node runtime found"
else
    echo "node runtime not found"
    exit -1
fi

if command -v R >/dev/null; then
    echo "R runtime found"
    export R_BIN="$(which R)"
else
    echo "R runtime not found"
    exit -1
fi

if command -v scala >/dev/null; then
    echo "scala runtime found"
else
    echo "scala runtime not found"
    exit -1
fi

./gradlew \
    clean \
    scalafmtAll \
    downloadPythonDependecies \
    build \
    test \
    shadowJar \
    rPackageDest \
    rPackageBuild \
    copyPythonExec \
    copyRExec \
    copyScalaExec

