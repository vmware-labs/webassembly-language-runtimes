use pyo3::prelude::*;

pub fn main() -> PyResult<()> {
    pyo3::prepare_freethreaded_python();

    Python::with_gil(|py| -> PyResult<()> {
        let fun: Py<PyAny> = PyModule::from_code(
            py,
            "def my_func(*args, **kwargs):
                print('Hello from Python(libpython3.11.a) in Wasm(Rust). args=', args)",
            "",
            "",
        )?
        .getattr("my_func")?
        .into();

        fun.call1(py, ("a1", "a2", 3, 4))?;
        Ok(())
    })
}
