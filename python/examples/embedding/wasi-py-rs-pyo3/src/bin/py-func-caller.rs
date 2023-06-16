use pyo3::{append_to_inittab, PyResult};

use wasi_py_rs_pyo3::call_function;
use wasi_py_rs_pyo3::py_module::make_person_module;

pub fn main() -> PyResult<()> {
    append_to_inittab!(make_person_module);

    let function_code = include_str!("py-func.py");
    call_function(
        "my_func",
        function_code,
        (
            ("John", 21, ["funny", "student"]),
            ("Jane", 22, ["thoughtful", "student"]),
            ("George", 75, ["wise", "retired"]),
        ),
    )
}
