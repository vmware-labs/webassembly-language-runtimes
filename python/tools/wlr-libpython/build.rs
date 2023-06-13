use path_absolutize::*;
use std::error;
use std::fmt;
use std::path;

type BoxedError = Box<dyn error::Error>;
struct LibsConfig {
    lib_paths: Vec<String>,
    libs: Vec<String>,
}

impl LibsConfig {
    fn new() -> LibsConfig {
        LibsConfig {
            lib_paths: vec![],
            libs: vec![],
        }
    }

    fn add_lib_path(&mut self, lib_path: String) {
        self.lib_paths.push(
            path::Path::new(&lib_path)
                .absolutize()
                .unwrap()
                .to_str()
                .unwrap()
                .to_string(),
        );
    }

    fn add(&mut self, lib: &str) {
        self.libs.push(lib.to_string());
    }

    fn emit_link_flags(&self) {
        for lib_path in &self.lib_paths {
            println!("cargo:rustc-link-search=native={lib_path}");
        }

        for lib in &self.libs {
            println!("cargo:rustc-link-lib={lib}");
            // println!("cargo:rustc-link-lib=static={lib}");
            // println!("cargo:rustc-link-lib=static:+whole-archive={lib}");
        }
    }
}

#[derive(Debug, Clone)]
struct DepsError {
    msg: String,
}

impl fmt::Display for DepsError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.msg)
    }
}

impl error::Error for DepsError {}

fn fetch_asset(asset_url: &str) -> Result<bytes::Bytes, BoxedError> {
    let response = reqwest::blocking::get(asset_url)?;

    if !response.status().is_success() {
        return Err(DepsError {
            msg: format!(
                "Failed to download '{}': HTTP {}",
                asset_url,
                response.status()
            ),
        }
        .into());
    }

    Ok(response.bytes()?)
}

fn unpack_archive(archive: bytes::Bytes, target_folder: &path::Path) -> Result<(), BoxedError> {
    use flate2::read::GzDecoder;
    use std::io::Cursor;
    use tar::Archive;

    let decoder = GzDecoder::new(Cursor::new(archive));
    let mut archive = Archive::new(decoder);
    archive.unpack(target_folder)?;

    Ok(())
}

fn download_asset(asset_url: &str, target_folder: &path::Path) -> Result<(), BoxedError> {
    use std::fs;
    fs::create_dir_all(&target_folder)?;

    let archive = fetch_asset(asset_url)?;
    unpack_archive(archive, target_folder)
}

const WASI_DEPS_PATH: &str = "target/wasm32-wasi/wasi-deps";

const WASI_SDK_SYSROOT_URL: &str = "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/wasi-sysroot-19.0.tar.gz";
const WASI_SDK_CLANG_BUILTINS_URL: &str = "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-19/libclang_rt.builtins-wasm32-wasi-19.0.tar.gz";
const LIBPYTHON_URL: &str = "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/python%2F3.11.3%2B20230428-7d1b259/libpython-3.11.3-wasi-sdk-19.0.tar.gz";

fn ensure_dependencies() -> Result<LibsConfig, BoxedError> {
    let mut libs_config = LibsConfig::new();

    let wasi_deps_path = path::Path::new(WASI_DEPS_PATH);

    download_asset(WASI_SDK_SYSROOT_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{WASI_DEPS_PATH}/wasi-sysroot/lib/wasm32-wasi"));
    libs_config.add("wasi-emulated-signal");
    libs_config.add("wasi-emulated-getpid");
    libs_config.add("wasi-emulated-process-clocks");

    download_asset(WASI_SDK_CLANG_BUILTINS_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{WASI_DEPS_PATH}/lib/wasi"));
    libs_config.add("clang_rt.builtins-wasm32");

    download_asset(LIBPYTHON_URL, wasi_deps_path)?;
    libs_config.add_lib_path(format!("{WASI_DEPS_PATH}/lib/wasm32-wasi"));
    libs_config.add("python3.11");

    Ok(libs_config)
}

fn main() -> Result<(), BoxedError> {

    use std::env;
    for (key, value) in env::vars() {
        println!("{key}: {value}");
    }

    let libs_config = ensure_dependencies()?;

    libs_config.emit_link_flags();


    Ok(())
}
