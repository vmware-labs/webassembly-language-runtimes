use std::error;
use std::fmt;
use std::path;

type BoxedError = Box<dyn error::Error>;
struct DependencyInfo {
    lib_paths: Vec<String>,
    libs: Vec<String>,
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

fn ensure_dependencies() -> Result<DependencyInfo, BoxedError> {
    let wasi_deps_path = path::Path::new(WASI_DEPS_PATH);

    let mut lib_paths: Vec<String> = vec![];
    let mut libs: Vec<String> = vec![];

    download_asset(WASI_SDK_SYSROOT_URL, wasi_deps_path)?;
    lib_paths.push(format!("{WASI_DEPS_PATH}/wasi-sysroot/lib/wasm32-wasi"));
    libs.push("wasi-emulated-signal".to_string());
    libs.push("wasi-emulated-getpid".to_string());
    libs.push("wasi-emulated-process-clocks".to_string());

    download_asset(WASI_SDK_CLANG_BUILTINS_URL, wasi_deps_path)?;
    lib_paths.push(format!("{WASI_DEPS_PATH}/lib/wasi"));
    libs.push("clang_rt.builtins-wasm32".to_string());

    download_asset(LIBPYTHON_URL, wasi_deps_path)?;
    lib_paths.push(format!("{WASI_DEPS_PATH}/lib/wasm32-wasi"));

    Ok(DependencyInfo { lib_paths, libs })
}

fn main() -> Result<(), BoxedError> {
    let deps = ensure_dependencies()?;

    for lib_path in deps.lib_paths {
        println!("cargo:rustc-link-search={lib_path}");
    }

    for lib in deps.libs {
        println!("cargo:rustc-link-lib={lib}");
    }

    Ok(())
}
