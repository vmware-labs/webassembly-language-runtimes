# About

## Building

You can build PHP by running the following Makefile targets:

- `make php-7.3.33`
- `make php-7.4.32`

## Running a script with php-cgi

Don't forget to map the folder that contains the php script, which you want to run. For example:

```bash
wasmtime --mapdir=./::./ -- php-cgi my-script.php
```
