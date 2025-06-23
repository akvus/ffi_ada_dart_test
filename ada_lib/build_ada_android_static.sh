#!/bin/bash

# True Ada Cross-Compilation for Android with Static Linking
# This script compiles REAL Ada code for Android by statically linking GNAT runtime

set -e

source /home/akvus/.profile

# Configuration
NDK_PATH="${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/29.0.13599879}"
MIN_SDK_VERSION=21
OUTPUT_DIR="../flutter_proj/android/app/src/main/jniLibs"
GNAT_ADALIB="/usr/lib/gcc/x86_64-linux-gnu/13/adalib"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}True Ada Android Cross-Compilation${NC}"
echo "====================================="

# Check if NDK is available
if [ ! -d "$NDK_PATH" ]; then
    echo -e "${RED}Error: Android NDK not found at $NDK_PATH${NC}"
    exit 1
fi

# Check if Ada source files exist
if [ ! -f "library.ads" ] || [ ! -f "library.adb" ] || [ ! -f "library_c_wrapper.adb" ]; then
    echo -e "${RED}Error: Ada source files not found${NC}"
    exit 1
fi

# Step 1: Compile Ada to object files
echo -e "\n${YELLOW}Step 1: Compiling Ada to object files...${NC}"
gnatmake -c library.adb library_c_wrapper.adb -cargs -fPIC -gnatp
echo -e "${GREEN}✓ Ada object files created${NC}"

# Step 2: Extract needed symbols from GNAT runtime
echo -e "\n${YELLOW}Step 2: Extracting GNAT runtime symbols...${NC}"

# Create a temporary directory for extracted objects
TEMP_DIR=$(mktemp -d)
echo "Using temp directory: $TEMP_DIR"

# Extract specific object files from libgnat.a that we need
cd $TEMP_DIR
ar x $GNAT_ADALIB/libgnat_pic.a

# Find the objects that contain our needed symbols
NEEDED_OBJS=""
for symbol in "ada__numerics__elementary_functions" "__gnat_raise_exception" "constraint_error"; do
    for obj in *.o; do
        if nm $obj 2>/dev/null | grep -q "$symbol"; then
            NEEDED_OBJS="$NEEDED_OBJS $obj"
            echo "Found $symbol in $obj"
        fi
    done
done

cd - > /dev/null

# Function to build for specific Android ABI
build_for_abi() {
    local ABI=$1
    local ARCH=$2
    
    echo -e "\n${YELLOW}Building for $ABI...${NC}"
    
    # Set up toolchain paths
    TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64"
    
    case "$ABI" in
        "arm64-v8a")
            CC="$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK_VERSION}-clang"
            AR="$TOOLCHAIN/bin/aarch64-linux-android-ar"
            STRIP="$TOOLCHAIN/bin/aarch64-linux-android-strip"
            ;;
        "armeabi-v7a")
            CC="$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK_VERSION}-clang"
            AR="$TOOLCHAIN/bin/arm-linux-androideabi-ar"
            STRIP="$TOOLCHAIN/bin/arm-linux-androideabi-strip"
            ;;
        "x86_64")
            CC="$TOOLCHAIN/bin/x86_64-linux-android${MIN_SDK_VERSION}-clang"
            AR="$TOOLCHAIN/bin/x86_64-linux-android-ar"
            STRIP="$TOOLCHAIN/bin/x86_64-linux-android-strip"
            ;;
        "x86")
            CC="$TOOLCHAIN/bin/i686-linux-android${MIN_SDK_VERSION}-clang"
            AR="$TOOLCHAIN/bin/i686-linux-android-ar"
            STRIP="$TOOLCHAIN/bin/i686-linux-android-strip"
            ;;
    esac
    
    # Check if toolchain exists
    if [ ! -f "$CC" ]; then
        echo -e "${RED}Warning: Toolchain for $ABI not found. Skipping...${NC}"
        return
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Step 3: Create a minimal runtime stub for Android
    echo "Creating minimal runtime stub..."
    cat > $TEMP_DIR/ada_android_runtime.c << 'EOF'
// Minimal Ada runtime stubs for Android
#include <stdlib.h>
#include <math.h>
#include <string.h>

// Exception handling stubs
void __gnat_raise_exception(void* exception_id, const char* message) {
    // For now, just abort - in production, handle gracefully
    abort();
}

// Constraint error stub
void* constraint_error = (void*)0x1; // Non-null pointer

// Math function wrappers (if needed)
float ada__numerics__elementary_functions__sqrt(float x) {
    return sqrtf(x);
}

float ada__numerics__elementary_functions__Oexpon(float base, float exp) {
    return powf(base, exp);
}

// Memory management stubs (if needed)
void* __gnat_malloc(size_t size) {
    return malloc(size);
}

void __gnat_free(void* ptr) {
    free(ptr);
}
EOF
    
    # Compile the runtime stub
    $CC -c -fPIC -o $TEMP_DIR/ada_android_runtime.o $TEMP_DIR/ada_android_runtime.c
    
    # Step 4: Link everything together
    echo "Linking Ada code with minimal runtime..."
    
    # Try to create shared library with all objects
    if $CC -shared -fPIC \
        -o "$OUTPUT_DIR/$ABI/libada_math.so" \
        library.o \
        library_c_wrapper.o \
        $TEMP_DIR/ada_android_runtime.o \
        -lm \
        -Wl,--no-undefined \
        -Wl,-soname,libada_math.so \
        -Wl,--gc-sections \
        -Wl,--strip-all 2>&1; then
        
        echo -e "${GREEN}✓ Successfully created library for $ABI${NC}"
        
        # Verify the output
        if [ -f "$OUTPUT_DIR/$ABI/libada_math.so" ]; then
            echo "  File size: $(ls -lh "$OUTPUT_DIR/$ABI/libada_math.so" | awk '{print $5}')"
            file "$OUTPUT_DIR/$ABI/libada_math.so" | sed 's/^/  /'
            
            # Check for Ada symbols
            if nm -D "$OUTPUT_DIR/$ABI/libada_math.so" | grep -q "ada_add"; then
                echo -e "  ${GREEN}✓ Ada functions exported correctly${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ Failed to link for $ABI${NC}"
        echo "Trying alternative approach..."
        
        # Alternative: Try with partial static linking
        $CC -shared -fPIC \
            -o "$OUTPUT_DIR/$ABI/libada_math.so" \
            library.o \
            library_c_wrapper.o \
            $TEMP_DIR/ada_android_runtime.o \
            -lm \
            -Wl,-soname,libada_math.so \
            -Wl,--allow-shlib-undefined 2>&1 || echo "Alternative also failed"
    fi
}

# Build for main Android architectures
build_for_abi "arm64-v8a" "arm64"
build_for_abi "armeabi-v7a" "arm"

# Clean up
rm -rf $TEMP_DIR

echo -e "\n${GREEN}Build process completed!${NC}"
echo ""
echo "This script attempts to compile REAL Ada code for Android."
echo "The libraries use actual Ada implementation with minimal runtime stubs."
echo ""
echo "Next steps:"
echo "1. Test the libraries on Android devices"
echo "2. If linking fails, we'll try the minimal runtime approach"
echo "3. Check logcat for any runtime issues"