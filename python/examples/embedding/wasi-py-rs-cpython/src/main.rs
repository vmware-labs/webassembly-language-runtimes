// Adapted from the Usage example for the cpython crate
// https://github.com/dgrunwald/rust-cpython#usage

use cpython::{Python, PyDict, PyResult};

fn main() {
    let gil = Python::acquire_gil();
    hello(gil.python()).unwrap();
}

fn hello(py: Python) -> PyResult<()> {
    let sys = py.import("sys")?;
    let version: String = sys.get(py, "version")?.extract(py)?;
    let platform: String = sys.get(py, "platform")?.extract(py)?;

    let locals = PyDict::new(py);
    locals.set_item(py, "os", py.import("os")?)?;
    let os_name: String = py.eval("os.name", None, Some(&locals))?.extract(py)?;

    println!("Hello! I'm Python {}, running on {}/{}", version, platform, os_name);
    Ok(())
}
