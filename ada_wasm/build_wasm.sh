#!/bin/bash

# AdaWebPack WASM Build Script
# Compiles Ada math library to WebAssembly

set -e  # Exit on any error

echo "=== Ada to WASM Build Script ==="
echo "Building Ada math library for WebAssembly..."

# Check for required tools
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed or not in PATH"
        echo "Please install AdaWebPack and its dependencies"
        exit 1
    fi
}

echo "Checking required tools..."
check_tool "wasm-ld"
check_tool "llvm-ar"

# Build directory setup
BUILD_DIR="build"
WASM_DIR="wasm_output"

echo "Setting up build directories..."
mkdir -p "$BUILD_DIR"
mkdir -p "$WASM_DIR"

# AdaWebPack compilation
echo "Compiling Ada sources to WASM..."

# Check if AdaWebPack is available
if [ -n "$ADAWEBPACK_HOME" ]; then
    echo "AdaWebPack home: $ADAWEBPACK_HOME"
    export PATH="$ADAWEBPACK_HOME/bin:$PATH"
fi

# Compilation flags for minimal WASM output
WASM_FLAGS="-gnatwa -gnatwe -O2 -ffunction-sections -fdata-sections"
WASM_BIND_FLAGS="-minimal-binder"
WASM_LINK_FLAGS="--gc-sections --no-entry --export-dynamic"

echo "=== Build Configuration ==="
echo "Source files:"
echo "  - library_wasm.ads"
echo "  - library_wasm.adb" 
echo "  - library_wasm_wrapper.ads"
echo "  - library_wasm_wrapper.adb"
echo ""
echo "Target: WebAssembly (WASM)"
echo "Output: $WASM_DIR/ada_math.wasm"
echo ""

# Compile Ada to LLVM bitcode
echo "Step 1: Compiling Ada to LLVM bitcode..."
llvm-gnatcompile -c $WASM_FLAGS library_wasm.adb -o "$BUILD_DIR/library_wasm.bc" || {
    echo "ERROR: Failed to compile library_wasm.adb"
    echo "Make sure AdaWebPack and GNAT-LLVM are properly installed"
    exit 1
}

llvm-gnatcompile -c $WASM_FLAGS library_wasm_wrapper.adb -o "$BUILD_DIR/library_wasm_wrapper.bc" || {
    echo "ERROR: Failed to compile library_wasm_wrapper.adb"
    exit 1
}

# Link LLVM bitcode files
echo "Step 2: Linking LLVM bitcode..."
llvm-link "$BUILD_DIR/library_wasm.bc" "$BUILD_DIR/library_wasm_wrapper.bc" -o "$BUILD_DIR/ada_math.bc" || {
    echo "ERROR: Failed to link bitcode files"
    exit 1
}

# Convert to WASM
echo "Step 3: Converting to WebAssembly..."
wasm-ld $WASM_LINK_FLAGS "$BUILD_DIR/ada_math.bc" -o "$WASM_DIR/ada_math.wasm" || {
    echo "ERROR: Failed to generate WASM file"
    exit 1
}

# Verify WASM output
echo "Step 4: Verifying WASM module..."
if [ -f "$WASM_DIR/ada_math.wasm" ]; then
    echo "SUCCESS: WASM module created at $WASM_DIR/ada_math.wasm"
    echo "File size: $(ls -lh "$WASM_DIR/ada_math.wasm" | awk '{print $5}')"
    
    # Optional: Use wasm-objdump to verify exports
    if command -v wasm-objdump &> /dev/null; then
        echo ""
        echo "Exported functions:"
        wasm-objdump -x "$WASM_DIR/ada_math.wasm" | grep -A 20 "Export"
    fi
else
    echo "ERROR: WASM file was not created"
    exit 1
fi

echo ""
echo "Build complete! Copy the WASM file to Flutter:"
echo "cp $WASM_DIR/ada_math.wasm ../flutter_proj/assets/wasm/"

# Create a project file for AdaWebPack
cat > ada_wasm_project.gpr << 'EOF'
project Ada_WASM_Project is
   for Source_Dirs use (".");
   for Object_Dir use "build";
   for Exec_Dir use "wasm_output";
   for Main use ("library_wasm_wrapper.adb");
   
   package Compiler is
      for Switches ("Ada") use ("-gnatwa", "-gnatwe", "-gnatyyM", "-gnaty3abcdefhijklmnoprstux");
   end Compiler;
   
   package Binder is
      for Switches ("Ada") use ("-Es");
   end Binder;
end Ada_WASM_Project;
EOF

echo "Created Ada project file: ada_wasm_project.gpr"
echo ""
echo "Next steps:"
echo "1. Install AdaWebPack"
echo "2. Update this script with correct AdaWebPack compilation commands"
echo "3. Run the build script to generate WASM module"