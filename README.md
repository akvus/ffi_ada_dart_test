# Ada-Dart FFI Test Project

A project demonstrating FFI (Foreign Function Interface) between Ada and Dart, featuring a mathematical library written in Ada that can be called from Dart applications via C-compatible shared library.

## 📁 Project Structure

```
ffi_ada_dart_test/
├── ada_lib/                        # Ada library source code
│   ├── Source Files
│   │   ├── library.ads            # Ada library specification (interface)
│   │   ├── library.adb            # Ada library implementation
│   │   ├── library_c_wrapper.ads  # C-compatible wrapper specification
│   │   └── library_c_wrapper.adb  # C-compatible wrapper implementation
│   │
│   ├── Test Programs
│   │   ├── test_library.adb       # Ada test program
│   │   └── test_c.c               # C test program
│   │
│   ├── Build Scripts
│   │   ├── Makefile               # Make-based build system
│   │   └── build_shared_library.sh # Shell script for building shared library
│   │
│   └── Build Artifacts
│       ├── libada_math.so         # Shared library for C/FFI usage
│       └── test_library           # Compiled Ada test executable
│
└── flutter_proj/                   # Flutter/Dart project (to be implemented)
```

## 🔧 Prerequisites

### GNAT (GNU Ada Compiler)
- **Ubuntu/Debian**: `sudo apt-get install gnat`
- **Fedora/RHEL**: `sudo dnf install gcc-gnat`
- **macOS**: `brew install gnat`
- **Windows**: Install GNAT Community Edition from AdaCore

### GCC (for C integration)
- Usually comes pre-installed on Linux/macOS
- Required for building the shared library and C test program

### Dart/Flutter (for Dart FFI)
- Install Flutter SDK from https://flutter.dev
- Dart SDK is included with Flutter

## 📖 Function Reference

The Ada library provides the following mathematical functions:

| Ada Function | C Function | Description |
|--------------|------------|-------------|
| `Add(A, B)` | `ada_add(a, b)` | Returns A + B |
| `Subtract(A, B)` | `ada_subtract(a, b)` | Returns A - B |
| `Multiply(A, B)` | `ada_multiply(a, b)` | Returns A × B |
| `Divide(A, B)` | `ada_divide(a, b)` | Returns A ÷ B (raises exception if B = 0) |
| `Square_Root(X)` | `ada_sqrt(x)` | Returns √X (raises exception if X < 0) |
| `Power(Base, Exponent)` | `ada_power(base, exp)` | Returns Base^Exponent |
| `Absolute_Value(X)` | `ada_abs(x)` | Returns \|X\| |
| `Maximum(A, B)` | `ada_max(a, b)` | Returns max(A, B) |
| `Minimum(A, B)` | `ada_min(a, b)` | Returns min(A, B) |

All functions use `Float` type (32-bit floating point) for parameters and return values.

### Error Handling
- `Divide`: Raises `Constraint_Error` if divisor is zero
- `Square_Root`: Raises `Constraint_Error` if argument is negative

## 🏗️ Building the Library

### Quick Start

```bash
cd ada_lib
make all        # Build everything
./test_library  # Run Ada test
```

### Detailed Build Options

#### Method 1: Using Make (Recommended)

```bash
cd ada_lib

# Build everything (Ada test + shared library)
make all

# Build only the Ada test program
make test

# Build only the shared library
make shared

# Run the Ada test program
make run-test

# Clean build artifacts
make clean
```

#### Method 2: Using Build Script

```bash
cd ada_lib
chmod +x build_shared_library.sh
./build_shared_library.sh
```

#### Method 3: Manual Compilation

For Ada usage:
```bash
cd ada_lib
gnatmake test_library.adb
./test_library
```

For C/FFI usage:
```bash
cd ada_lib

# Compile Ada sources with Position Independent Code
gcc -c -fPIC library.adb
gcc -c -fPIC library_c_wrapper.adb

# Create shared library
gcc -shared -o libada_math.so library.o library_c_wrapper.o -lgnat -lm

# Verify exported functions
nm -D libada_math.so | grep ada_
```

## 💻 Usage Examples

### Using from Ada

```ada
with Ada.Text_IO;
with Library;

procedure My_Program is
   Result : Float;
begin
   -- Direct usage of library functions
   Result := Library.Add(10.0, 5.0);
   Ada.Text_IO.Put_Line("10 + 5 = " & Float'Image(Result));
   
   Result := Library.Square_Root(16.0);
   Ada.Text_IO.Put_Line("√16 = " & Float'Image(Result));
end My_Program;
```

Compile and run:
```bash
gnatmake my_program.adb
./my_program
```

### Using from C

```c
#include <stdio.h>

// Declare the Ada functions
extern float ada_add(float a, float b);
extern float ada_subtract(float a, float b);
extern float ada_multiply(float a, float b);
extern float ada_divide(float a, float b);
extern float ada_sqrt(float x);
extern float ada_power(float base, float exponent);
extern float ada_abs(float x);
extern float ada_max(float a, float b);
extern float ada_min(float a, float b);

int main() {
    printf("10 + 5 = %.2f\n", ada_add(10.0f, 5.0f));
    printf("√16 = %.2f\n", ada_sqrt(16.0f));
    return 0;
}
```

Compile and run:
```bash
cd ada_lib

# Compile the C program and link with the Ada library
gcc -o my_c_program my_c_program.c -L. -lada_math -lgnat -lm

# Run (make sure libada_math.so is in library path)
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
./my_c_program
```

### Using from Dart (FFI)

```dart
import 'dart:ffi';
import 'dart:io';

// Define function signatures
typedef AdaAddC = Float Function(Float a, Float b);
typedef AdaAddDart = double Function(double a, double b);

void main() {
  // Load the shared library
  final dylib = Platform.isLinux
      ? DynamicLibrary.open('./ada_lib/libada_math.so')
      : DynamicLibrary.open('./ada_lib/libada_math.dylib'); // macOS

  // Look up the functions
  final adaAdd = dylib
      .lookup<NativeFunction<AdaAddC>>('ada_add')
      .asFunction<AdaAddDart>();

  // Use the function
  final result = adaAdd(10.0, 5.0);
  print('10 + 5 = $result');
}
```

## 🧪 Testing

### Running the Ada Test Program

```bash
cd ada_lib
make test
./test_library
```

Expected output:
```
Testing Ada Library Functions
=============================
Add(10.0, 5.0) =  1.50000E+01
Subtract(10.0, 5.0) =  5.00000E+00
Multiply(10.0, 5.0) =  5.00000E+01
Divide(10.0, 5.0) =  2.00000E+00
Square_Root(25.0) =  5.00000E+00
Power(2.0, 3.0) =  8.00000E+00
Absolute_Value(-15.5) =  1.55000E+01
Maximum(10.0, 20.0) =  2.00000E+01
Minimum(10.0, 20.0) =  1.00000E+01
=============================
All tests completed successfully!
```

### Running the C Test Program

```bash
cd ada_lib

# Compile the C test
gcc -o test_c test_c.c -L. -lada_math -lgnat -lm

# Run the test
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
./test_c
```

Expected output:
```
Testing Ada Library from C
==========================
ada_add(10.0, 5.0) = 15.00
ada_subtract(10.0, 5.0) = 5.00
ada_multiply(10.0, 5.0) = 50.00
ada_divide(10.0, 5.0) = 2.00
ada_sqrt(25.0) = 5.00
ada_power(2.0, 3.0) = 8.00
ada_abs(-15.5) = 15.50
ada_max(10.0, 20.0) = 20.00
ada_min(10.0, 20.0) = 10.00
```

## 🔍 Troubleshooting

### Common Issues

1. **"gnatmake: command not found"**
   - Install GNAT compiler (see Prerequisites)

2. **"cannot find -lgnat" when linking C program**
   - Ensure GNAT runtime libraries are installed
   - Add GNAT library path: `export LIBRARY_PATH=/usr/lib/gcc/x86_64-linux-gnu/13:$LIBRARY_PATH`

3. **"error while loading shared libraries: libada_math.so"**
   - Add current directory to library path: `export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH`
   - Or install the library: `sudo cp libada_math.so /usr/local/lib/`

4. **Compilation errors with -gnaty flags**
   - Remove style checking flags from Makefile
   - Use simplified flags: `-gnat2012` only

### Verifying the Shared Library

```bash
cd ada_lib

# Check if library was created
ls -la libada_math.so

# View exported functions
nm -D libada_math.so | grep ada_

# Check library dependencies
ldd libada_math.so
```

## 🚀 Next Steps

- [ ] Complete Flutter/Dart FFI integration
- [ ] Add more mathematical functions (trigonometry, logarithms, etc.)
- [ ] Add support for different numeric types (Integer, Long_Float)
- [ ] Create bindings for other languages (Python, Ruby, etc.)
- [ ] Add performance benchmarks comparing Ada, C, and Dart implementations
- [ ] Implement error callbacks for better exception handling across FFI

## 📝 License

This is a demonstration project for Ada/C/Dart FFI integration.