use pyo3::{types::PyModule, PyResult, Python};

#[derive(Clone)]
#[pyo3::pyclass]
#[pyo3(name = "Person")]
pub struct Person {
    #[pyo3(get, set)]
    name: String,
    #[pyo3(get, set)]
    age: u16,
    #[pyo3(get)]
    tags: Vec<String>,
}

#[pyo3::pymethods]
impl Person {
    #[new]
    fn new(name: String, age: u16) -> Self {
        Self {
            name,
            age,
            tags: vec![],
        }
    }

    fn add_tag(&mut self, tag: String) {
        self.tags.push(tag);
    }

    fn __str__(&self) -> PyResult<String> {
        Ok(format!(
            "Person(Name: \"{}\", Age: {}, Tags:{:?})",
            self.name, self.age, self.tags
        ))
    }

    fn __repr__(&self) -> PyResult<String> {
        self.__str__()
    }
}

#[pyo3::pyfunction]
pub fn filter_by_tag(people: Vec<Person>, tag: String) -> Vec<Person> {
    let mut result: Vec<Person> = vec![];
    for p in people.iter() {
        if p.tags.iter().any(|t| t == &tag) {
            result.push(p.clone());
        }
    }
    result
}

#[pyo3::pymodule]
#[pyo3(name = "person")]
pub fn make_person_module(_py: Python<'_>, module: &PyModule) -> PyResult<()> {
    module.add_function(pyo3::wrap_pyfunction!(filter_by_tag, module)?)?;
    module.add_class::<Person>()
}
