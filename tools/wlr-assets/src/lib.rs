pub mod bld_cfg;

use std::error::Error;
use std::fmt::{Display, Formatter, Result as FmtResult};
use std::path::Path;

type BoxedError = Box<dyn Error>;

pub fn download_asset(asset_url: &str, target_folder: &Path) -> Result<(), BoxedError> {
    use std::fs;
    fs::create_dir_all(&target_folder)?;

    let archive = fetch_asset(asset_url)?;
    unpack_archive(archive, target_folder)
}

#[derive(Debug, Clone)]
struct AssetsError {
    msg: String,
}

impl Display for AssetsError {
    fn fmt(&self, f: &mut Formatter) -> FmtResult {
        write!(f, "{}", self.msg)
    }
}

impl Error for AssetsError {}

fn fetch_asset(asset_url: &str) -> Result<bytes::Bytes, BoxedError> {
    let response = reqwest::blocking::get(asset_url)?;

    if !response.status().is_success() {
        return Err(AssetsError {
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

fn unpack_archive(archive: bytes::Bytes, target_folder: &Path) -> Result<(), BoxedError> {
    use flate2::read::GzDecoder;
    use std::io::Cursor;
    use tar::Archive;

    let decoder = GzDecoder::new(Cursor::new(archive));
    let mut archive = Archive::new(decoder);
    archive.unpack(target_folder)?;

    Ok(())
}
