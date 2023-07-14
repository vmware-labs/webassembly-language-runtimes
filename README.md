# webassembly-language-runtimes

WebAssembly Language Runtimes (or WLR for short) offers pre-built wasm32-wasi binaries for language runtimes and static builds of common open source libraries.

This repository contains the build scripts and patches that are used to do those builds, as well as examples on how to use them.

## Try it out

WLR is used in projects like [mod_wasm](https://github.com/vmware-labs/mod_wasm) for traditional deployments and [Wasm Workers Server](https://github.com/vmware-labs/wasm-workers-server) for the development of serverless apps. To get a glimpse of that you could:

 - [5 min] Run [WordPress with php.wasm, mod_wasm and Apache](https://wasmlabs.dev/articles/running-wordpress-with-mod-wasm/). (You'll need Docker for a container with Apache).
 - [10 min] Create and run a [Ruby worker on wws](https://workers.wasmlabs.dev/docs/languages/ruby).

The released assets are also easy to use with various platforms and tools.

 - [5 min] Take a look at how to [run the python-wasm Docker container](./python/examples/#running-the-docker-container). (You'll need the latest Docker Desktop with enabled containerd).
 - [10 min] Follow the steps in Fermyon's blog post on [PHP, Spin and Fermyon cloud](https://www.fermyon.com/blog/php-spin-fermyon-cloud).

If you are into porting of C-based apps to wasm32-wasi you could play with the libs.

 - [10 min] Build a [C-app that uses the libuuid and zlib](./libs/examples//uuid_zlib_example/#the-app) static libraries.
 - [1 day – 2 weeks] Port a static library. Take a look at the build scripts for [`libs/zlib`](./libs/zlib/) as an example. Pick a library you want to see ported. Try building it to wasm32-wasi. (Prior knowledge of building C apps with autotools, make, cmake, pkg-config will be an advantage).


## Releases

Here is a reference to the latest releases of all built projects.

| Language runtime          | Latest release            |
|---                        |---                        |
| [php](./php/)             | [8.2.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/php%2F8.2.0%2B20230418-d75a618)             |
| [python](./python/)       | [3.11.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/python%2F3.11.3%2B20230428-7d1b259)        |
| [ruby](./ruby/)           | [3.2.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/ruby%2F3.2.0%2B20230215-1349da9)            |



| Library                                   | Latest release            |
|---                                        |---                        |
| [libs/bundle_wlr](./libs/bundle_wlr)      | [0.1.0](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fbundle_wlr%2F0.1.0%2B20230310-ddace6c)   |
| [libs/bzip2](./libs/bzip2)                | [1.0.8](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fbzip2%2F1.0.8%2B20230425-e1a7579)  |
| [libs/libjpeg](./libs/libjpeg)            | [2.1.5.1](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibjpeg%2F2.1.5.1%2B20230310-c46e363)  |
| [libs/libpng](./libs/libpng)              | [1.6.39](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibpng%2F1.6.39%2B20230310-13a5f2e)  |
| [libs/libuuid](./libs/libuuid)            | [1.0.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibuuid%2F1.0.3%2B20230310-c46e363)  |
| [libs/libxml2](./libs/libxml2)            | [2.10.3](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Flibxml2%2F2.10.3%2B20230310-c46e363)   |
| [libs/oniguruma](./libs/oniguruma)        | [6.9.8](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Foniguruma%2F6.9.8%2B20230310-c46e363)   |
| [libs/sqlite](./libs/sqlite)              | [3.41.2](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fsqlite%2F3.41.2%2B20230329-43f9aea)  |
| [libs/zlib](./libs/zlib)                  | [1.2.13](https://github.com/vmware-labs/webassembly-language-runtimes/releases/tag/libs%2Fzlib%2F1.2.13%2B20230310-c46e363)   |

## For developers

If you want to contribute to this project or run a build on your own machine, take a look at the [./docs/developers.md](./docs/developers.md) documentation.
