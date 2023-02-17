#!/bin/bash

# This file contains all examples snippets combined together

if [[ "$(realpath $PWD)" != "$(realpath $(dirname $BASH_SOURCE))" ]]
then
  echo "This script works only if called from its location as PWD"
  exit 1
fi

set -x

echo -e "\n\n>>>> Prepare the artifacts"
mkdir tmp
wget https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1.wasm -O tmp/python-3.11.1.wasm
wget https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1-wasmedge.wasm -O tmp/python-3.11.1-wasmedge.wasm

mkdir tmp/unpacked
curl -sL https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1.tar.gz | tar xzv -C tmp/unpacked

tree -h tmp


echo -e "\n\n>>>> First time running python.wasm"
wasmtime run \
  tmp/python-3.11.1.wasm \
  -- -c "import sys; from pprint import pprint as pp; \
         pp(sys.path); pp(sys.platform)"

wasmtime run \
  --mapdir /::$PWD/tmp/unpacked/ \
  tmp/unpacked/bin/python-3.11.1.wasm \
  -- -c "import sys; from pprint import pprint as pp; \
         pp(sys.path); pp(sys.platform)"

wasmedge \
  --dir /:$PWD/tmp/unpacked/ \
  tmp/unpacked/bin/python-3.11.1-wasmedge.wasm \
  -c "import sys; from pprint import pprint as pp; \
      pp(sys.path); pp(sys.platform)"


echo -e "\n\n>>>> Installing dependencies to the pre-compiled PYTHONPATH"
pip3 install emoji -t tmp/unpacked/usr/local/lib/python3.11/

wasmtime run \
  --mapdir /workdir::$PWD/workdir \
  --mapdir /::$PWD/tmp/unpacked  \
  tmp/unpacked/bin/python-3.11.1.wasm  \
  -- \
  workdir/emojize_text.py workdir/source_text.txt


echo -e "\n\n>>>> Using a virtual environment"
python3 -m venv tmp/venv-emoji
. tmp/venv-emoji/bin/activate
pip3 install emoji
deactivate

wasmtime \
  --env PYTHONPATH=/external-packages \
  --mapdir /external-packages::$PWD/tmp/venv-emoji/lib/python3.11/site-packages \
  --mapdir workdir::$PWD/workdir \
  tmp/python-3.11.1.wasm \
  -- \
  workdir/emojize_text.py workdir/source_text.txt

wasmedge \
  --env PYTHONPATH=/external-packages \
  --dir /external-packages:$PWD/tmp/venv-emoji/lib/python3.11/site-packages \
  --dir workdir:$PWD/workdir \
  tmp/python-3.11.1-wasmedge.wasm \
  workdir/emojize_text.py workdir/source_text.txt


echo -e "\n\n>>>> Running the docker container"

docker run --rm \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
  -c "import os; print([k for k in os.environ.keys()])"


echo -e "\n\n>>>> Running the docker container with dependencies"
docker run --rm \
  -v $PWD/tmp/venv-emoji/lib/python3.11/site-packages:/usr/local/lib/python3.11/site-packages \
  -v $PWD/workdir/:/workdir/ \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
  -- \
  workdir/emojize_text.py workdir/source_text.txt


echo -e "\n\n>>>> Wrapping it all in a new container image"
cat > tmp/Dockerfile.emojize <<EOF
FROM ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge

COPY tmp/venv-emoji/ /opt/venv-emoji/
COPY workdir/emojize_text.py /opt

ENV PYTHONPATH /opt/venv-emoji/lib/python3.11/site-packages

ENTRYPOINT [ "python.wasm", "/opt/emojize_text.py" ]
EOF


docker build \
  --platform=wasm32/wasi \
  -f tmp/Dockerfile.emojize \
  -t emojize.py-wasm .


docker run --rm \
  -v $PWD/workdir/source_text.txt:/source_text.txt \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  emojize.py-wasm \
  source_text.txt

set +x

echo -e "\n\n>>>> Cleanup"
rm -rf tmp

