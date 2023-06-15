
def my_func(*args, **kwargs):
    import sys
    print(f'Hello from Python (libpython3.11.a / {sys.version}) in Wasm(Rust).\nargs={args}\n')

    import person
    people = []
    for name, age, tags in args:
        p = person.Person(name, age)
        for t in tags:
            p.add_tag(t)
        people.append(p)

    from pprint import pprint as pp
    filter_tag = 'student'
    filtered = person.filter_by_tag(people, filter_tag)
    print('Original people:')
    pp(people)
    print(f'Filtered people by `{filter_tag}`:')
    pp(filtered)
