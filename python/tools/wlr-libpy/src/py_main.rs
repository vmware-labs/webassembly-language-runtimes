use std::ffi::CString;
use std::os::raw::{c_char, c_int};

mod cpython {
    use std::os::raw::{c_char, c_int};
    extern "C" {
        pub fn Py_BytesMain(argc: c_int, argv: *mut *mut c_char) -> c_int;
    }
}

fn to_raw_args(args: Vec<String>) -> Vec<*mut c_char> {
    let mut raw_args: Vec<_> = args
        .into_iter()
        .map(|x| CString::new(x).unwrap().into_raw())
        .collect();
    raw_args.push(std::ptr::null_mut());
    raw_args
}

pub fn py_main(args: Vec<String>) -> i32 {
    let mut argv = to_raw_args(args);
    let argc = (argv.len() - 1) as c_int;
    unsafe { cpython::Py_BytesMain(argc, argv.as_mut_ptr()) }
}
