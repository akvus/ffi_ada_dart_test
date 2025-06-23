#!/bin/bash

# Build Ada Math Library using Android NDK ndk-build
# This creates .so files for all Android ABIs

set -e

source /home/akvus/.profile

# Configuration
NDK_PATH="${ANDROID_NDK_HOME:-$HOME/Android/Sdk/ndk/29.0.13599879}"
OUTPUT_DIR="../flutter_proj/android/app/src/main/jniLibs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Building Ada Math Library with ndk-build${NC}"
echo "============================================="

# Check if NDK is available
if [ ! -d "$NDK_PATH" ]; then
    echo -e "${RED}Error: Android NDK not found at $NDK_PATH${NC}"
    exit 1
fi

# Check if ndk-build exists
NDK_BUILD="$NDK_PATH/ndk-build"
if [ ! -f "$NDK_BUILD" ]; then
    echo -e "${RED}Error: ndk-build not found at $NDK_BUILD${NC}"
    exit 1
fi

# Clean previous builds
echo -e "\n${YELLOW}Cleaning previous builds...${NC}"
rm -rf obj/ libs/

# Build with ndk-build
echo -e "\n${YELLOW}Building with ndk-build...${NC}"
cd jni

$NDK_BUILD -j$(nproc) V=1

cd ..

# Check results
if [ -d "libs" ]; then
    echo -e "\n${GREEN}✓ Build successful!${NC}"
    echo "Libraries built:"
    find libs -name "*.so" -exec ls -la {} \;
    
    # Copy to Flutter jniLibs directory
    echo -e "\n${YELLOW}Copying to Flutter project...${NC}"
    mkdir -p "$OUTPUT_DIR"
    
    for abi_dir in libs/*/; do
        abi=$(basename "$abi_dir")
        mkdir -p "$OUTPUT_DIR/$abi"
        
        if [ -f "$abi_dir/libada_math.so" ]; then
            cp "$abi_dir/libada_math.so" "$OUTPUT_DIR/$abi/"
            echo "✓ Copied $abi/libada_math.so"
        fi
    done
    
    echo -e "\n${GREEN}✓ Libraries ready for Flutter!${NC}"
    echo "Location: $OUTPUT_DIR"
    
else
    echo -e "\n${RED}✗ Build failed!${NC}"
    exit 1
fi

echo -e "\n${GREEN}ndk-build completed successfully!${NC}"
echo ""
echo "Libraries built with ndk-build:"
echo "- Supports all Android ABIs"
echo "- Includes Android logging"
echo "- Optimized for release"
echo ""
echo "Next steps:"
echo "1. Test with: flutter run"
echo "2. Check logcat for Ada function calls"