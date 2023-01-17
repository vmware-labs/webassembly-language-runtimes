# About

## Building

You can build Ruby by running the following Makefile targets:

- `make v3_2_0`

## Running a script with ruby

Don't forget to map the folder that contains the ruby script, which you want to run. For example:

```bash
wasmtime --mapdir=./::./ -- ruby my-script.rb
```
