use pyo3::append_to_inittab;
use wasi_py_rs_pyo3::py_module::make_person_module;
use wlr_libpy::py_main::py_main;

pub fn main() {
    append_to_inittab!(make_person_module);

    py_main(std::env::args().collect());
}
