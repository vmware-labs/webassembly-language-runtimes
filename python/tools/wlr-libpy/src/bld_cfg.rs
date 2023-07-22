use wlr_assets::bld_cfg::LibsConfig;
use wlr_assets::download_asset;

use std::error::Error;
use std::path::Path;

type BoxedError = Box<dyn Error>;

const WASI_DEPS_PATH: &str = "target/wasm32-wasi/wasi-deps";

const WASI_SDK_SYSROOT_URL: &str = "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sysroot-20.0.tar.gz";
const WASI_SDK_CLANG_BUILTINS_URL: &str = "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/libclang_rt.builtins-wasm32-wasi-20.0.tar.gz";
const LIBPYTHON_URL: &str = "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.4%2B20230714-11be424/libpython-3.11.4-wasi-sdk-20.0.tar.gz";

pub fn configure_static_libs() -> Result<LibsConfig, BoxedError> {
    let mut libs_config = LibsConfig::new();

    let out_dir = if let Ok(mut out_dir) = std::env::var("OUT_DIR") {
        if let Some(position) = out_dir.rfind("/wasm32-wasi/") {
            out_dir.truncate(position + 13);
            out_dir.push_str("wasi-deps");
            Some(out_dir)
        } else {
            None
        }
    } else {
        None
    }
    .unwrap_or_else(|| WASI_DEPS_PATH.into());
    let wasi_deps_path = Path::new(&out_dir);

    download_asset(WASI_SDK_SYSROOT_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{out_dir}/wasi-sysroot/lib/wasm32-wasi"));
    libs_config.add("wasi-emulated-signal");
    libs_config.add("wasi-emulated-getpid");
    libs_config.add("wasi-emulated-process-clocks");

    download_asset(WASI_SDK_CLANG_BUILTINS_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{out_dir}/lib/wasi"));
    libs_config.add("clang_rt.builtins-wasm32");

    download_asset(LIBPYTHON_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{out_dir}/lib/wasm32-wasi"));
    libs_config.add("python3.11");

    Ok(libs_config)
}
