Here you can find a list of things to try out with Python.wasm

The latest release is available at [python/3.11.1+20230217-15dfbed](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/python%2F3.11.1%2B20230217-15dfbed)

If you hate walls of text and just want to look at the sample commands, take a look at [run_all_snippets.sh](./run_all_snippets.sh). You could even run it (from this folder as PWD) to try and reproduce most of the examples below.

# Prerequisites

To give it a try, you will need to have a few tools installed in advance.

Most notably, a shell that has enough Unicode support to show emojis. Yep, this is what we use as part of our examples 😄

Naturally, you'll need some basic tools to handle the artifacts - curl, wget, tar, gzip.

### Python3 on your host machine

Implementing pip for `python.wasm` is not universally possible, because WASI still does not offer full socket support. Downloading a package from the internet may not even work on some runtimes.

But that is OK for most scenarios we are interested in, as `python.wasm` is likely to be used as a runtime in Cloud or Edge environments rather than a generic development platform. We will start by using a native python3.11 installation to setup a sample application. And then we will show how you can run it on `python.wasm`.

### A WASI-compatible runtime

As `python.wasm` is built for WASI you will need to get a compatible WebAssembly runtime, such as [Wasmtime](https://wasmtime.dev/). We also provide an additional binary that will run on [WasmEdge](https://wasmedge.org/), which offers extended socket support on top of a modified WASI API. Since Docker+Wasm uses WasmEdge, this is the binary you will need if you want to build a WASM container image to use with Docker, as explained later in the article.

### Docker+Wasm

To try the examples with Docker you will need "Docker Desktop" + Wasm [version 4.15](https://docs.docker.com/desktop/release-notes/#4150) or later.

## Release artifacts

If you take a look at the release assets, you will find a few flavors:

 - `python-3.11.1.wasm` - WASI compliant interpreter and standard libs wrapped within a single Wasm binary
 - `python-3.11.1-wasmedge.wasm` - WASI+WasmEdge compliant interpreter and standard libs wrapped within a single Wasm binary. WasmEdge extends WASI's socket API
 - `python-3.11.1.tar.gz` - Both the WASI and WASI+WasmEdge interpreters as separate Wasm binaries. The standard libs are also available separately. All of these within the same archive.

 You would want to use the first two versions when convenience is the most important factor. You get a single binary and you don't have to manage how it uses the Python standard library. It all just works.

 The last version is useful in more flexible configurations where a few running Wasm binaries may reuse the same set of standard library files.

 Additionally, you can use two flavors of a Docker image:

 - `ghcr.io/vmware-labs/python-wasm:3.11.1`, which can run on any WASI-compliant containerd runtime
 - `ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge`, which can run on the WasmEdge containerd runtime (WasmEdge supports additional socket APIs)

# Setup

All of the examples below assume you are using the same working directory as this README.md file. Some of them build on top of each other. Where this is the case we have tried referencing the previous one that we step on.

First, prepare a temporary folder and download the different flavors of `python.wasm` binaries

```shell-session
mkdir tmp
wget https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1.wasm -O tmp/python-3.11.1.wasm
wget https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1-wasmedge.wasm -O tmp/python-3.11.1-wasmedge.wasm

mkdir tmp/unpacked
curl -sL https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.1%2B20230217-15dfbed/python-3.11.1.tar.gz | tar xzv -C tmp/unpacked
```

Now, let's look into what we downloaded. The `python-3.11.1-wasmedge.wasm` and `python-3.11.1.wasm` binaries inside `tmp` can be used as standalone interpreters, as they embed the Python standard libraries.

The ones in `tmp/unpacked/bin`, however, will need the files from `tmp/unpacked/usr/local/lib` to work. These files include a `python311.zip` archive of the standard libraries, a placeholder `python3.11/lib-dynload` and a `python3.11/os.py`. The last two are not strictly necessary but if omitted will cause dependency warnings whenever python runs.

```shell-session
tmp
├── [ 12M]  python-3.11.1-wasmedge.wasm
├── [ 19M]  python-3.11.1.wasm
└── [4.0K]  unpacked
    ├── [4.0K]  bin
    │   ├── [7.6M]  python-3.11.1-wasmedge.wasm
    │   └── [ 14M]  python-3.11.1.wasm
    └── [4.0K]  usr
        └── [4.0K]  local
            └── [4.0K]  lib
                ├── [4.0K]  python3.11
                │   ├── [4.0K]  lib-dynload
                │   └── [ 39K]  os.py
                └── [3.9M]  python311.zip
```

# First time running python.wasm

Running the packed binaries is as easy as

```shell-session
wasmtime run \
  tmp/python-3.11.1.wasm \
  -- -c "import sys; from pprint import pprint as pp; \
         pp(sys.path); pp(sys.platform)"
['',
 '/usr/local/lib/python311.zip',
 '/usr/local/lib/python3.11',
 '/usr/local/lib/python3.11/lib-dynload']
'wasi'
```

To use the unpacked version we will need to pre-open the `usr/local/lib` folder as relative to the root path `/`, because `python.wasm` is compiled to look for it there. For Wasmtime this is done via `--mapdir`.

```shell-session
wasmtime run \
  --mapdir /::$PWD/tmp/unpacked/ \
  tmp/unpacked/bin/python-3.11.1.wasm \
  -- -c "import sys; from pprint import pprint as pp; \
         pp(sys.path); pp(sys.platform)"

['',
 '/usr/local/lib/python311.zip',
 '/usr/local/lib/python3.11',
 '/usr/local/lib/python3.11/lib-dynload']
'wasi'
```

We could do the same with the WasmEdge-compliant binary (note the slight differences in the CLI arguments).

```shell-session
wasmedge \
  --dir /:$PWD/tmp/unpacked/ \
  tmp/unpacked/bin/python-3.11.1-wasmedge.wasm \
  -c "import sys; from pprint import pprint as pp; \
      pp(sys.path); pp(sys.platform)"

['',
 '/usr/local/lib/python311.zip',
 '/usr/local/lib/python3.11',
 '/usr/local/lib/python3.11/lib-dynload']
'wasi'
```

## Running the repl

If you want, you can play with the Python repl.

```shell-session
wasmtime run tmp/unpacked/bin/python-3.11.1.wasm

Python 3.11.1 (tags/v3.11.1:a7a450f, Feb 17 2023, 12:59:00) ... on wasi
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>>
>>> sys.platform
'wasi'
>>>
>>> sys.version_info
sys.version_info(major=3, minor=11, micro=1, releaselevel='final', serial=0)
```

## Running an app with dependencies

Next, let's assume we have a Python app that has additional dependencies. For example [emojize_text.py](./workdir/emojize_text.py).

### Installing dependencies to the pre-compiled PYTHONPATH

To set up the dependencies we will need `pip3` (or `python3 -m pip`) on the development machine, to download and install the necessary dependencies. The most straightforward way of doing this is by running pip with `--target` pointing to the path that is already pre-compiled into the `python.wasm` binary. Namely, `usr/local/lib/python3.11/`

However, we could use this approach only with the version where the python interpreter is not packed with the standard libraries. In this case the host folder with the standard libraries (along with the extra dependencies that we installed) will be pre-opened to the proper location within the Wasm application at runtime.

```shell-session
pip3 install emoji -t tmp/unpacked/usr/local/lib/python3.11/
```

Now we can run our text _emojizer_. Taking a look at the sample source text.

```shell-session
cat workdir/source_text.txt

The rabbit woke up with a smile.
The sunrise was shining on his face.
A carrot was waiting for him on the table.
He will put on his jeans and get out of the house for a walk.
```

We get this result from `emojize_text.py`
```shell-session
wasmtime run \
  --mapdir /workdir::$PWD/workdir \
  --mapdir /::$PWD/tmp/unpacked  \
  tmp/unpacked/bin/python-3.11.1.wasm  \
  -- \
  workdir/emojize_text.py workdir/source_text.txt

The 🐇 woke up with a smile.
The 🌅 was shining on his face.
A 🥕 was waiting for him on the table.
He will put on his 👖 and get out of the 🏠 for a walk.
```

### Using a virtual environment

Any more complex python application is likely to be using virtual environments. In that case, you will have a `venv` folder with all requirements pre-installed. All you need to leverage them is to:

 - Make sure this folder is pre-opened when running `python.wasm`
 - Add it to the `PYTHONPATH` environment variable

Let's take a look at how to do this.

We will start by creating a virtual environment within the same folder and installing 'emoji' in it.

```shell-session
python3 -m venv tmp/venv-emoji
. tmp/venv-emoji/bin/activate
pip3 install emoji
deactivate
```

We will need to pre-open the folder with the venv modules (`tmp/venv-emoji/lib/python3.11/site-packages`) and add it to `PYTHONPATH` accordingly. 

```shell-session
wasmtime \
  --env PYTHONPATH=/external-packages \
  --mapdir /external-packages::$PWD/tmp/venv-emoji/lib/python3.11/site-packages \
  --mapdir workdir::$PWD/workdir \
  tmp/python-3.11.1.wasm \
  -- \
  workdir/emojize_text.py workdir/source_text.txt

The 🐇 woke up with a smile.
The 🌅 was shining on his face.
A 🥕 was waiting for him on the table.
He will put on his 👖 and get out of the 🏠 for a walk.
```

Passing an environment variable with WasmEdge is similar

```shell-session
wasmedge \
  --env PYTHONPATH=/external-packages \
  --dir /external-packages:$PWD/tmp/venv-emoji/lib/python3.11/site-packages \
  --dir workdir:$PWD/workdir \
  tmp/python-3.11.1-wasmedge.wasm \
  workdir/emojize_text.py workdir/source_text.txt
...
```

## Running the Docker container

Docker+WASM uses the WasmEdge runtime internally. To leverage it we have packaged the python-3.11.1-wasmedge.wasm binary in a container image available as `ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge`.

Here is an example of running the Python repl from this container image. As you can see from the output of the interactive session, the container includes only `python.wasm` and the standard libraries from `usr`. No base OS images, no extra environment variables, or any other clutter.

```shell-session
docker run --rm \
  -i \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
  -i

Python 3.11.1 (tags/v3.11.1:a7a450f, Feb 17 2023, 11:01:02) ...  on wasi
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys
>>>
>>> sys.platform
>>> 'wasi'
>>>
>>> import os
>>> os.listdir('.')
['python.wasm', 'etc', 'usr']
>>>
>>> [k for k in os.environ.keys()]
['PATH', 'HOSTNAME']
```

You can also run the Docker container to execute a one-liner like this.

```shell-session
docker run --rm \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
  -c "import os; print([k for k in os.environ.keys()])"

['PATH', 'HOSTNAME']
```

## Running the Docker container with dependencies

The `python-wasm` container image comes by default just with the Python standard library, so if your project has extra dependencies you will need to take care of them. Let's reuse the `venv-emoji` environment in which we installed `emoji` in [the example above](#using-a-virtual-environment).

We need to do three things

1. Ensure that the `emoji` module installed in the `venv-emoji` folder is mounted in the running `python-wasm` container
2. Ensure that it is also on the `PYTHONPATH` within the running `python-wasm` container
3. Ensure that the python program and its data (in this case `workdir/emojize_text.py` and `workdir/source_text.txt`) are also mounted in the container

A vital piece of knowledge here is that whatever you mount in the running container gets automatically pre-opened by the WasmEdge runtime. Same goes for all environment variables that you pass to the container when you run it. 

One way of doing what we want is to just mount `site-packages` from `venv-emoji` over the `site-packages` folder of the pre-compiled path in `/usr/local`. This is how this could look like:

```shell-session
docker run --rm \
  -v $PWD/tmp/venv-emoji/lib/python3.11/site-packages:/usr/local/lib/python3.11/site-packages \
  -v $PWD/workdir/:/workdir/ \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
  -- \
  workdir/emojize_text.py workdir/source_text.txt

The 🐇 woke up with a smile.
The 🌅 was shining on his face.
A 🥕 was waiting for him on the table.
He will put on his 👖 and get out of the 🏠 for a walk.
```

## Wrapping it all in a new container image

This way of running your python application with the `python-wasm` container is too cumbersome. Luckily OCI and Docker already offer a way to package everything nicely.

Let's first create a Dockerfile that steps on `python-wasm` to package our emojize_text.py app and its `venv` into a single image.

```shell-session
cat > tmp/Dockerfile.emojize <<EOF
FROM ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge

COPY tmp/venv-emoji/ /opt/venv-emoji/
COPY workdir/emojize_text.py /opt

ENV PYTHONPATH /opt/venv-emoji/lib/python3.11/site-packages

ENTRYPOINT [ "python.wasm", "/opt/emojize_text.py" ]
EOF
```

Building the container is straightforward

```shell-session
docker build \
  --platform=wasm32/wasi \
  -f tmp/Dockerfile.emojize \
  -t emojize.py-wasm .
```

And to run it we only have to mount and provide the data file.

```shell-session
docker run --rm \
  -v $PWD/workdir/source_text.txt:/source_text.txt \
  --runtime=io.containerd.wasmedge.v1 \
  --platform=wasm32/wasi \
  emojize.py-wasm \
  source_text.txt

The 🐇 woke up with a smile.
The 🌅 was shining on his face.
A 🥕 was waiting for him on the table.
He will put on his 👖 and get out of the 🏠 for a walk.
```

# To recap

This page covers some basic examples of Python.wasm.

If you want to share more use-cases with the community, feel free to contribute by extending this file.

Also, if you are interested at what comes next for Python.wasm drop us a comment in Github at [Python.wasm roadmap #46](https://github.com/vmware-labs/webassembly-language-runtimes/issues/46).
