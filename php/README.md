# About

## Building

You can build PHP by running the following Makefile targets:

- `make v8.1.11`
- `make v8.2.0`
- `make v8.2.0-slim`
- `make v8.2.6`
- `make v8.2.6-slim`

## Running a script with php-cgi

Don't forget to map the folder that contains the php script, which you want to run. For example:

```bash
wasmtime --mapdir=./::./ -- php-cgi my-script.php
```
