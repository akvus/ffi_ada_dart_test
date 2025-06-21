#!/bin/bash

# Test script for Ada Android compilation approaches
# This script tests different methods to compile Ada code for Android

set -e

source /home/akvus/.profile

echo "Testing Ada Android compilation approaches..."
echo "============================================="

# Check Android NDK
echo "1. Checking Android NDK..."
if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Error: ANDROID_NDK_HOME not set or directory doesn't exist"
    exit 1
fi

NDK_TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
echo "NDK Toolchain: $NDK_TOOLCHAIN"

# Test 1: Try to compile Ada with custom C compiler
echo -e "\n2. Testing Ada compilation with Android NDK clang..."

# ARM64 target
echo "Testing ARM64 compilation..."
ARM64_CC="$NDK_TOOLCHAIN/bin/aarch64-linux-android21-clang"

if [ -f "$ARM64_CC" ]; then
    echo "ARM64 clang found: $ARM64_CC"
    
    # Try to compile with GNAT using Android clang
    echo "Attempting Ada compilation with Android clang..."
    
    # Method 1: Try to use GNAT with custom C compiler
    if gnatmake --help | grep -q "cargs"; then
        echo "Trying gnatmake with custom C compiler..."
        
        # This might not work, but let's try
        gnatmake -c library.adb -cargs -fPIC 2>&1 | head -10 || echo "Failed with default approach"
        
        # Try with explicit C compiler
        # Note: This is experimental and might not work
        echo "Trying with explicit C compiler path..."
        CC="$ARM64_CC" gnatmake -c library.adb -cargs -fPIC 2>&1 | head -10 || echo "Failed with CC override"
    fi
    
    # Method 2: Create a shell script wrapper
    echo "Creating wrapper script..."
    cat > /tmp/android_gcc_wrapper.sh << 'EOF'
#!/bin/bash
# Wrapper to make Android clang behave like gcc for GNAT
exec "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang" "$@"
EOF
    chmod +x /tmp/android_gcc_wrapper.sh
    
    # Try with wrapper
    PATH="/tmp:$PATH" CC="android_gcc_wrapper.sh" gnatmake -c library.adb -cargs -fPIC 2>&1 | head -10 || echo "Failed with wrapper approach"
    
else
    echo "ARM64 clang not found at $ARM64_CC"
fi

# Test 2: Check if we can compile object files and link separately
echo -e "\n3. Testing separate compilation and linking..."

# Try to compile Ada to object files with native GNAT
echo "Compiling Ada to object files with native GNAT..."
gnatmake -c library.adb library_c_wrapper.adb -cargs -fPIC || echo "Failed to compile Ada objects"

if [ -f library.o ] && [ -f library_c_wrapper.o ]; then
    echo "Ada object files created successfully"
    
    # Try to link with Android NDK
    echo "Attempting to link with Android NDK..."
    "$ARM64_CC" -shared -o libada_math_android_arm64.so library.o library_c_wrapper.o -lm 2>&1 | head -10 || echo "Linking failed"
    
    if [ -f libada_math_android_arm64.so ]; then
        echo "Success! Created libada_math_android_arm64.so"
        file libada_math_android_arm64.so
        ls -la libada_math_android_arm64.so
    fi
else
    echo "Could not create Ada object files"
fi

echo -e "\n4. Testing runtime dependencies..."
if [ -f libada_math_android_arm64.so ]; then
    echo "Checking dependencies of created library:"
    readelf -d libada_math_android_arm64.so || echo "Could not read dependencies"
fi

echo -e "\nTest completed."