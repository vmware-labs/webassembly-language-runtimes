use path_absolutize::*;
use std::path::Path;

pub struct LibsConfig {
    lib_paths: Vec<String>,
    libs: Vec<String>,
}

impl LibsConfig {
    pub fn new() -> LibsConfig {
        LibsConfig {
            lib_paths: vec![],
            libs: vec![],
        }
    }

    pub fn add_lib_path(&mut self, lib_path: String) {
        self.lib_paths.push(
            Path::new(&lib_path)
                .absolutize()
                .unwrap()
                .to_str()
                .unwrap()
                .to_string(),
        );
    }

    pub fn add(&mut self, lib: &str) {
        self.libs.push(lib.to_string());
    }

    pub fn emit_link_flags(&self) {
        for lib_path in &self.lib_paths {
            println!("cargo:rustc-link-search=native={lib_path}");
        }

        for lib in &self.libs {
            println!("cargo:rustc-link-lib={lib}");
        }
    }
}
