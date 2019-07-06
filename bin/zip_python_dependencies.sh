#!/usr/bin/env bash

cd streaming

cat << 'EOF' > ~/.pydistutils.cfg
[install]
prefix=
EOF

pip3 install \
    -t dependencies \
    -r pinned.txt

zip -r dependencies.zip dependencies

rm -rf ~/.pydistutils.cfg
