use pyo3::{append_to_inittab, PyResult};

use wasi_py_rs::call_function;
use wasi_py_rs::py_module::make_person_module;

pub fn main() -> PyResult<()> {
    append_to_inittab!(make_person_module);

    let function_code = "def my_func(*args, **kwargs):
    import sys
    print(f'Hello from Python (libpython3.11.a / {sys.version}) in Wasm(Rust).\\nargs=', args)

    import person
    people = []
    for name, age, tags in args:
        p = person.Person(name, age)
        for t in tags:
            p.add_tag(t)
        people.append(p)

    filtered = person.filter_by_tag(people, 'student')
    print(f'Original people: {people}')
    print(f'Filtered people by `student`: {filtered}')
    ";

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
