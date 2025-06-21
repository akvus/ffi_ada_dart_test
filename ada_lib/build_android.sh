#!/bin/bash

# Android Ada Library Cross-Compilation Build Script
# This script builds the Ada math library for Android architectures
# Requires: Android NDK and GNAT compiler with Android support

set -e

# Configuration - Update these paths according to your environment
NDK_PATH="${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/25.2.9519653}"
MIN_SDK_VERSION=21
OUTPUT_DIR="../flutter_proj/android/app/src/main/jniLibs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Android Ada Library Build Script${NC}"
echo "======================================"

# Check if NDK is available
if [ ! -d "$NDK_PATH" ]; then
    echo -e "${RED}Error: Android NDK not found at $NDK_PATH${NC}"
    echo "Please set ANDROID_NDK_HOME environment variable or update NDK_PATH in this script"
    exit 1
fi

# Check if Ada source files exist
if [ ! -f "ada_math.ads" ] || [ ! -f "ada_math.adb" ] || [ ! -f "ada_math_c_wrapper.adb" ]; then
    echo -e "${RED}Error: Ada source files not found in current directory${NC}"
    exit 1
fi

# Function to build for a specific Android ABI
build_for_abi() {
    local ABI=$1
    local ARCH=$2
    local TRIPLE=$3
    local PLATFORM=$4
    
    echo -e "\n${YELLOW}Building for $ABI...${NC}"
    
    # Set up toolchain paths
    TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64"
    CC="$TOOLCHAIN/bin/${TRIPLE}${MIN_SDK_VERSION}-clang"
    AR="$TOOLCHAIN/bin/llvm-ar"
    SYSROOT="$TOOLCHAIN/sysroot"
    
    # Check if toolchain exists
    if [ ! -f "$CC" ]; then
        echo -e "${RED}Warning: Toolchain for $ABI not found. Skipping...${NC}"
        return
    fi
    
    # Note: This is a template script. Actual Ada cross-compilation for Android
    # requires a GNAT compiler built for Android targets, which is not commonly available.
    # The following commands show what would be needed:
    
    echo "  Would compile with:"
    echo "  - Target: $TRIPLE"
    echo "  - Architecture: $ARCH"
    echo "  - Platform: android-$MIN_SDK_VERSION"
    echo "  - Output: $OUTPUT_DIR/$ABI/libada_math.so"
    
    # Placeholder for actual Ada cross-compilation commands
    # In practice, you would need:
    # 1. GNAT cross-compiler for Android (e.g., from AdaCore GNAT Pro)
    # 2. Proper runtime libraries for Android
    # 3. Commands like:
    #    gnatmake -g -fPIC --target=$TRIPLE --sysroot=$SYSROOT \
    #             -largs -shared -o libada_math.so ada_math_c_wrapper.adb
    
    # For now, we'll create a placeholder file to show the structure
    mkdir -p "$OUTPUT_DIR/$ABI"
    echo "Placeholder for $ABI build - requires GNAT Android cross-compiler" > "$OUTPUT_DIR/$ABI/README.txt"
}

# Build for each Android ABI
build_for_abi "armeabi-v7a" "arm" "arm-linux-androideabi" "android-16"
build_for_abi "arm64-v8a" "arm64" "aarch64-linux-android" "android-21"
build_for_abi "x86" "x86" "i686-linux-android" "android-16"
build_for_abi "x86_64" "x86_64" "x86_64-linux-android" "android-21"

echo -e "\n${GREEN}Build process completed!${NC}"
echo -e "${YELLOW}Note: This is a template script. To actually build Ada libraries for Android, you need:${NC}"
echo "1. GNAT compiler with Android cross-compilation support (e.g., GNAT Pro)"
echo "2. Android runtime libraries for Ada"
echo "3. Proper linking with Android's libc and libm"
echo ""
echo "Alternative approaches:"
echo "- Use AdaCore's GNAT Pro with Android support"
echo "- Build a C stub that calls Ada code compiled for Linux (using QEMU user-mode)"
echo "- Rewrite critical functions in C for Android compatibility"