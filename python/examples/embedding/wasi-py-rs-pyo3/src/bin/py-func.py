def my_func(*args, **kwargs):
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
