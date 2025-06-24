# WASM Assets Directory

This directory should contain the compiled Ada WASM module.

## Expected File:
- `ada_math.wasm` - The compiled Ada math library

## How to Generate:

1. Install AdaWebPack from https://github.com/godunko/adawebpack
2. Navigate to `ada_wasm/` directory
3. Run `./build_wasm.sh`
4. Copy the generated `ada_math.wasm` file to this directory

## Temporary Solution:

Until AdaWebPack is installed and the WASM module is compiled, the app will show an error when trying to load the WASM module. This is expected behavior.

The HTML bridge will report: "Failed to fetch WASM module: 404 Not Found"
