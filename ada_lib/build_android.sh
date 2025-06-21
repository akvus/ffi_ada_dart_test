#!/bin/bash

# Android Ada Library Cross-Compilation Build Script
# This script builds the Ada math library for Android architectures
# Requires: Android NDK and GNAT compiler with Android support

set -e

# Configuration - Update these paths according to your environment
NDK_PATH="${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/29.0.13599879}"
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

# Check if C implementation exists
if [ ! -f "ada_math_android.c" ]; then
    echo -e "${RED}Error: ada_math_android.c not found in current directory${NC}"
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
    
    # Map ABI to actual compiler names in NDK
    case "$ABI" in
        "armeabi-v7a")
            CC="$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK_VERSION}-clang"
            ;;
        "arm64-v8a")
            CC="$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK_VERSION}-clang"
            ;;
        "x86")
            CC="$TOOLCHAIN/bin/i686-linux-android${MIN_SDK_VERSION}-clang"
            ;;
        "x86_64")
            CC="$TOOLCHAIN/bin/x86_64-linux-android${MIN_SDK_VERSION}-clang"
            ;;
        *)
            echo -e "${RED}Unknown ABI: $ABI${NC}"
            return 1
            ;;
    esac
    
    AR="$TOOLCHAIN/bin/llvm-ar"
    SYSROOT="$TOOLCHAIN/sysroot"
    
    # Check if toolchain exists
    if [ ! -f "$CC" ]; then
        echo -e "${RED}Warning: Toolchain for $ABI not found. Skipping...${NC}"
        return
    fi
    
    # Check if C implementation exists
    if [ ! -f "ada_math_android.c" ]; then
        echo -e "${RED}Error: ada_math_android.c not found${NC}"
        return 1
    fi
    
    echo "  Compiling C implementation for $ABI..."
    echo "  - Target: $TRIPLE"
    echo "  - Architecture: $ARCH"
    echo "  - Platform: android-$MIN_SDK_VERSION"
    echo "  - Output: $OUTPUT_DIR/$ABI/libada_math.so"
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR/$ABI"
    
    # Compile C implementation for this ABI
    if "$CC" -shared -fPIC -o "$OUTPUT_DIR/$ABI/libada_math.so" \
            ada_math_android.c -lm \
            -Wl,--build-id=none -Wl,--no-undefined \
            -Wl,-soname,libada_math.so; then
        echo -e "  ${GREEN}✓ Successfully compiled for $ABI${NC}"
        
        # Verify the output
        if [ -f "$OUTPUT_DIR/$ABI/libada_math.so" ]; then
            echo "  File size: $(ls -lh "$OUTPUT_DIR/$ABI/libada_math.so" | awk '{print $5}')"
            file "$OUTPUT_DIR/$ABI/libada_math.so" | sed 's/^/  /'
        fi
    else
        echo -e "  ${RED}✗ Failed to compile for $ABI${NC}"
        return 1
    fi
}

# Build for each Android ABI
build_for_abi "armeabi-v7a" "arm" "armv7a-linux-androideabi" "android-$MIN_SDK_VERSION"
build_for_abi "arm64-v8a" "arm64" "aarch64-linux-android" "android-$MIN_SDK_VERSION"
build_for_abi "x86" "x86" "i686-linux-android" "android-$MIN_SDK_VERSION"
build_for_abi "x86_64" "x86_64" "x86_64-linux-android" "android-$MIN_SDK_VERSION"

echo -e "\n${GREEN}Build process completed!${NC}"
echo ""
echo "C implementation compiled for Android architectures."
echo "This provides the same mathematical functions as the Ada library"
echo "but uses standard C math functions for maximum compatibility."
echo ""
echo "Libraries created in: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Test the Flutter app with these libraries: flutter run"
echo "2. If you prefer the original Ada implementation, you would need:"
echo "   - GNAT compiler with Android cross-compilation support"
echo "   - Ada runtime libraries for Android"
