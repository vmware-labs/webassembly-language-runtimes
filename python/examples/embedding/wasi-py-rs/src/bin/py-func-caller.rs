use pyo3::{append_to_inittab, PyResult};

use wasi_py_rs::call_function;
use wasi_py_rs::py_module::make_person_module;

pub fn main() -> PyResult<()> {
    append_to_inittab!(make_person_module);

    let function_code = include_str!("py-func.py");
    call_function(
        "my_func",
        function_code,
        (
            ("John", 21, ["male", "student"]),
            ("Jane", 22, ["female", "student"]),
            ("George", 75, ["male", "retired"]),
        ),
    )
}
