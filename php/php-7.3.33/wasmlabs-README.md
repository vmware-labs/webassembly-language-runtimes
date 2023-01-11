# About

This contains a non-exhaustive list of changes that we had to make to be able to build the PHP codebase for wasm32-wasi.

To remove or add code for wasm32-wasi builds we are using the 'WASM_WASI' macro.

# emulated functionality

We are using emulation of getpid, signals and clocks.

We are not using mman emulation due to the reasons outlined [below](#mmap-support).

# excluded code

This describes the most common places where we needed to exclude code because
a method or constant is not available or is somehow different with WASI.

## S_IFSOCK is the same as  S_IFFIFO

WASI snapshot2 is not out yet - https://github.com/nodejs/uvwasi/issues/59.

Thus there is no support for a FIFO filetype. So the two constants were
defined to the same value. Because of this a switch/case on file type will fail
due to duplicate case labels.

We've commented out the S_IFFIFO cases.

## setjmp and longjmp

There is no such support in WASI yet.

We have taken a shortcut and just botched the exception handling in the zend
zend engine. The program will just ignore exceptions as they happen.

## sqlite3 support

We are using sqlite 3.39.2 instead of the original 3.28.0 that goes with php 7.3.33.

Additionally sqlite3 had to be modified in some ways for WASM_WASI builds:

 - mark fchmod, fchown as not defined
 - use "dotlockIoFinder" for file locking
 - skip sqlite3_finalize

## unsupported posix methods

We have stubbed the posix methods in `ext/posix/posix.c` which are not supported for WASI.

Other methods, which are direcly used without wrapping were skipped in place by stubbing
the method that is calling them.

## php flock

File locking is also stubbed and always returns success.

## mmap support

**TL;DR:** 

We are building without MMAP support. To make it work, changes had to be made to zend_alloc.c resulting in a slower but correct behavior.


**Details:** 

Take a look [here](https://linux.die.net/man/2/mmap) for the docs for mmap and munmap

The mmap support in wasi-libc is just a rudimentary emulation (as of the wasi-sdk-19 tag).

 - mmap uses malloc to reserve the necessary amount of memory (always ignoring the addr hint)
 - mmap zeroes out bytes if MAP_ANONYMOUS is used
 - mmap reads file contents if mapping an fd
 - munmap only supports unmapping of the exact same chunk (addr + size) that was previously mapped - as it is effectively a free of the malloc-ed memory

In the php code there are two places where mman.h is used

1. In zend_alloc.c - for custom memory allocation

 - there is code that relies on partial munmap (for the sake of proper alignment at higher level). Using the emulated mmap will lead to leaks here, as munmap fails.
 - there is code that relies on the capability to extend a mmaped chunk - this will fail and lead to performance degradation (falling-back to reallocation)

2. In plain_wrapper.c and zend_stream.c - for reading of the interpreted .php source files

 - the tricky thing here is the ZEND_MMAP_AHEAD needed by the zend_language_scanner. The language parser depends on having a bunch of null-terminating characters at the end of the interpreted string. The usual mmap behavior guarantees that when files are mmaped memory is reserved in pages of size `sysconf(_SC_PAGE_SIZE)`, which is padded with `\0`-s after the file contents. However, the emulated mmap does not do that (as it only malloc-s what was requested). This leads to the parser reading random stuff from memory after the mmaped file contents. 


