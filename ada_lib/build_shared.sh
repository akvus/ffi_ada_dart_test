#!/bin/bash

# Build script for creating shared library from Ada code

echo "Building Ada shared library for Dart FFI..."

# Check if GNAT is installed
if ! command -v gnatmake &> /dev/null
then
    echo "Error: GNAT compiler not found. Please install GNAT first."
    echo "On Ubuntu/Debian: sudo apt-get install gnat"
    echo "On Fedora: sudo dnf install gcc-gnat"
    echo "On macOS: brew install gnat"
    exit 1
fi

# Compile with position-independent code
echo "Compiling Ada sources..."
gnatmake -c library.adb -fPIC -gnat2012
gnatmake -c library_c_wrapper.adb -fPIC -gnat2012

# Create shared library
echo "Creating shared library..."
gnatbind -shared -x library_c_wrapper.ali
gcc -shared -o libada_math.so library.o library_c_wrapper.o -lgnat -lm

if [ -f "libada_math.so" ]; then
    echo "Success! Shared library created: libada_math.so"
    echo ""
    echo "Exported functions:"
    nm -D libada_math.so | grep ada_
else
    echo "Error: Failed to create shared library"
    exit 1
fi