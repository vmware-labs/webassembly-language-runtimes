// Based on https://rob-blackbourn.github.io/blog/webassembly/wasm/strings/javascript/c/libc/wasm-libc/clang/2020/06/20/wasm-string-passing.html

class WasmBuffer {
  array;

  constructor(array) {
    this.array = array;
  }

  getPtr() {
    return this.array.byteOffset;
  }

  getSize() {
    return this.array.byteLength;
  }

  setBytes(byteArray) {
    if (byteArray.length > this.getSize())
      throw new Error(`Trying to set ${byteArray.length} bytes, but allocated ${this.getSize()}!`);
    this.array.set(byteArray);
  }
}

class WasmMemoryManager {
  constructor(moduleExports) {
    this.memory = moduleExports.memory
    this.allocate = moduleExports.allocate
    this.deallocate = moduleExports.deallocate
  }

  allocateBuf(length) {
    const ptr = this.allocate(length);
    const array = new Uint8Array(this.memory.buffer, ptr, length);
    return new WasmBuffer(array);
  }

  wrapBuf(ptr, length) {
    return new WasmBuffer(new Uint8Array(this.memory.buffer, ptr, length));
  }

  deallocateBuf(buffer) {
    this.deallocate(buffer.getPtr(), buffer.getSize());
  }

  bufFromString(string) {
    // Encode the string in utf-8.
    const encoder = new TextEncoder();
    const bytes = encoder.encode(string);
    let buffer = this.allocateBuf(bytes.length + 1);
    buffer.setBytes(bytes);
    return buffer;
  }

  strFromBuf(buffer) {
    // The buffer contains a multi byte character array encoded with utf-8.
    const decoder = new TextDecoder();
    const string = decoder.decode(buffer.array);
    return string;
  }
}

module.exports = {
  WasmMemoryManager: WasmMemoryManager
}
