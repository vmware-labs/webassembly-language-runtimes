use wlr_assets::bld_cfg::LibsConfig;
use wlr_assets::download_asset;

use std::error::Error;
use std::path::Path;

type BoxedError = Box<dyn Error>;

struct LibPythonConfig {
    wasi_deps_path: &'static str,
    wasi_sdk_sysroot_url: &'static str,
    wasi_sdk_clang_builtins_url: &'static str,
    libpython_url: &'static str,
    libpython_binary: &'static str,
}

impl LibPythonConfig {
    pub fn get_deps_path(&self, subpath: &str) -> String {
        format!("{0}/{1}", self.wasi_deps_path, subpath)
    }
}

#[cfg(feature = "py311")]
const LIBPYTHON_CONF : LibPythonConfig = LibPythonConfig {
    wasi_deps_path: "target/wasm32-wasi/wasi-deps",
    wasi_sdk_sysroot_url: "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sysroot-20.0.tar.gz",
    wasi_sdk_clang_builtins_url: "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/libclang_rt.builtins-wasm32-wasi-20.0.tar.gz",
    libpython_url: "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.4%2B20230714-11be424/libpython-3.11.4-wasi-sdk-20.0.tar.gz",
    libpython_binary: "python3.11"
};

#[cfg(feature = "py312")]
const LIBPYTHON_CONF : LibPythonConfig = LibPythonConfig {
    wasi_deps_path: "target/wasm32-wasi/wasi-deps",
    wasi_sdk_sysroot_url: "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sysroot-20.0.tar.gz",
    wasi_sdk_clang_builtins_url: "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/libclang_rt.builtins-wasm32-wasi-20.0.tar.gz",
    libpython_url: "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.12.0%2B20231211-040d5a6/libpython-3.12.0-wasi-sdk-20.0.tar.gz",
    libpython_binary: "python3.12"
};

pub fn configure_static_libs() -> Result<LibsConfig, BoxedError> {
    let mut libs_config = LibsConfig::new();

    let wasi_deps_path = Path::new(LIBPYTHON_CONF.wasi_deps_path);

    download_asset(LIBPYTHON_CONF.wasi_sdk_sysroot_url, wasi_deps_path)?;
    libs_config.add_lib_path(LIBPYTHON_CONF.get_deps_path("wasi-sysroot/lib/wasm32-wasi"));
    libs_config.add("wasi-emulated-signal");
    libs_config.add("wasi-emulated-getpid");
    libs_config.add("wasi-emulated-process-clocks");

    download_asset(LIBPYTHON_CONF.wasi_sdk_clang_builtins_url, wasi_deps_path)?;
    libs_config.add_lib_path(LIBPYTHON_CONF.get_deps_path("lib/wasi"));
    libs_config.add("clang_rt.builtins-wasm32");

    download_asset(LIBPYTHON_CONF.libpython_url, wasi_deps_path)?;
    libs_config.add_lib_path(LIBPYTHON_CONF.get_deps_path("lib/wasm32-wasi"));
    libs_config.add(LIBPYTHON_CONF.libpython_binary);

    Ok(libs_config)
}
