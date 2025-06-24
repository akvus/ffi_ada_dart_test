# Ada to WASM Implementation

This directory contains the Ada code adapted for WebAssembly compilation using AdaWebPack.

## Overview

This implementation provides an alternative approach to calling Ada math functions from Flutter by:
1. Compiling Ada code to WebAssembly using AdaWebPack
2. Loading the WASM module in a WebView with JavaScript bridge
3. Communicating between Flutter and Ada via WebView messaging

## Architecture

```
Flutter Dart Code
       ↕ (WebView messaging)
JavaScript Bridge (HTML page)
       ↕ (WASM function calls)
WebAssembly Module
       ↕ (compiled from)
Ada Source Code
```

## Files Structure

- `library_wasm.ads/adb` - WASM-adapted Ada math library
- `library_wasm_wrapper.ads/adb` - C-compatible wrapper for WASM export
- `build_wasm.sh` - Build script for AdaWebPack compilation
- `ada_wasm_project.gpr` - GNAT project file for WASM build

## Key Adaptations for WASM

### 1. Error Handling
Instead of raising exceptions (which have limited WASM support), error conditions return special values:
- Division by zero: returns `Float'First`
- Square root of negative: returns `Float'First`
- Additional validation functions: `Is_Valid_Division`, `Is_Valid_Square_Root`

### 2. Export Interface
Functions are exported with C convention for WASM compatibility:
```ada
function wasm_add(A, B : Float) return Float
  with Export, Convention => C, External_Name => "wasm_add";
```

### 3. No Nested Subprograms
All functions are implemented at package level to comply with WASM constraints.

## Building the WASM Module

### Prerequisites

1. Install AdaWebPack following instructions at: https://github.com/godunko/adawebpack
2. Ensure you have:
   - GNAT-LLVM compiler
   - wasm-ld (WebAssembly linker)  
   - LLVM/Clang version 16

### Build Process

```bash
cd ada_wasm
chmod +x build_wasm.sh
./build_wasm.sh
```

The build script will:
1. Check for required tools
2. Set up build directories
3. Compile Ada sources to WASM
4. Generate `ada_math.wasm` and `ada_math.js` files

### Output Files

After successful compilation:
- `wasm_output/ada_math.wasm` - The WebAssembly module
- `wasm_output/ada_math.js` - JavaScript bindings (if generated)

## Integration with Flutter

The compiled WASM module is used by:
1. `flutter_proj/assets/html/wasm_bridge.html` - HTML page that loads WASM
2. `flutter_proj/lib/ada_wasm_bridge.dart` - Dart interface to WebView
3. `flutter_proj/lib/wasm_calculator_screen.dart` - Flutter UI

## Available Functions

All original Ada math functions are available via WASM:

| Ada Function | WASM Export | JavaScript Interface |
|--------------|-------------|---------------------|
| `Add(A, B)` | `wasm_add` | `AdaMath.add(a, b)` |
| `Subtract(A, B)` | `wasm_subtract` | `AdaMath.subtract(a, b)` |
| `Multiply(A, B)` | `wasm_multiply` | `AdaMath.multiply(a, b)` |
| `Divide(A, B)` | `wasm_divide` | `AdaMath.divide(a, b)` |
| `Square_Root(X)` | `wasm_sqrt` | `AdaMath.sqrt(x)` |
| `Power(Base, Exp)` | `wasm_power` | `AdaMath.power(base, exp)` |
| `Absolute_Value(X)` | `wasm_abs` | `AdaMath.abs(x)` |
| `Maximum(A, B)` | `wasm_max` | `AdaMath.max(a, b)` |
| `Minimum(A, B)` | `wasm_min` | `AdaMath.min(a, b)` |

## Development Notes

### Current Status
- ✅ Ada code adapted for WASM constraints
- ✅ Build script ready for real WASM compilation
- ✅ Flutter WebView integration with real WASM loader
- ✅ Proper error handling for missing WASM module
- ⏳ AdaWebPack compilation pending (requires AdaWebPack installation)
- ⏳ Real WASM module testing pending

### Real WASM Implementation
The HTML bridge now loads the actual WASM module from `assets/wasm/ada_math.wasm`. The implementation includes:
- Proper WebAssembly instantiation with import object
- Support for Ada runtime functions
- WASI imports for compatibility
- Verification of all required exports
- Detailed error messages for debugging

### Testing
To test the WASM integration:
1. Run the Flutter app: `flutter run` (from flutter_proj directory)
2. Select "Ada WASM Calculator"
3. Test various math operations
4. Check WebView console for debug messages

## Troubleshooting

### AdaWebPack Installation Issues
- Ensure all dependencies are installed (LLVM 16, wasm-ld, etc.)
- Check AdaWebPack documentation for platform-specific requirements
- Verify PATH includes AdaWebPack tools

### WASM Loading Issues
- Check browser console for WebAssembly loading errors
- Ensure WASM file is correctly generated and accessible
- Verify CORS settings if loading from file system

### Flutter WebView Issues
- Ensure webview_flutter dependency is properly installed
- Check platform-specific WebView requirements (iOS/Android)
- Verify assets are correctly bundled in pubspec.yaml

## Next Steps

1. Install AdaWebPack toolchain
2. Complete WASM compilation process
3. Replace mock JavaScript implementation with real WASM calls
4. Performance testing and optimization
5. Add more comprehensive error handling
6. Consider adding more mathematical functions