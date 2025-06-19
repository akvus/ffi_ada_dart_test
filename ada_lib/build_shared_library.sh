#!/bin/bash

# Clean up any existing files
rm -f *.o *.ali libada_math.so

echo "Building Ada shared library..."

# Compile Ada source files with Position Independent Code (-fPIC)
echo "Compiling library.adb..."
gcc -c -fPIC library.adb

echo "Compiling library_c_wrapper.adb..."
gcc -c -fPIC library_c_wrapper.adb

# Create shared library
echo "Creating shared library libada_math.so..."
gcc -shared -o libada_math.so library.o library_c_wrapper.o -lgnat -lm

# Clean up object files
rm -f *.o *.ali

echo "Shared library built successfully!"
echo ""
echo "Exported functions:"
nm -D libada_math.so | grep ada_ | grep " T "