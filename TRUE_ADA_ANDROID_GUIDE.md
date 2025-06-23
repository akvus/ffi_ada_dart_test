# True Ada Cross-Compilation for Android

## Current Status
- ❌ **Android**: Uses C implementation (`ada_math_android.c`)
- ✅ **Linux**: Uses real Ada code (`library.adb`)

## How to Get TRUE Ada on Android

### Option 1: AdaCore GNAT Pro (RECOMMENDED)

**What it is**: Commercial Ada compiler with official Android support

**Features**:
- GNAT Pro 7.2+ for Android ARM Cortex processors
- Supports Android 2.3+ on Cortex A8 and above
- Native ARM code generation
- Ada-Java interfacing system (AJIS)
- Professional support from AdaCore

**Steps**:
1. **Contact AdaCore**: Email info@adacore.com for licensing
2. **Purchase License**: Commercial license required for proprietary apps
3. **Install**: GNAT Pro for Android (Windows/Linux host)
4. **Cross-compile**: Use provided Android toolchain
   ```bash
   arm-linux-androideabi-gnatmake -P android_project.gpr
   ```

**Pros**: Official support, tested, reliable
**Cons**: Commercial license required (~$15k-50k+ annually)

### Option 2: GNAT LLVM (EXPERIMENTAL)

**What it is**: Open-source GNAT compiler using LLVM backend

**Requirements**:
```bash
# Install LLVM development libraries
sudo apt install llvm-dev clang-dev

# Clone GNAT LLVM
git clone https://github.com/AdaCore/gnat-llvm.git
cd gnat-llvm

# Build (requires existing GNAT)
make
```

**Cross-compilation**:
```bash
# Set Android target
export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
export CXX=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++

# Compile with GNAT LLVM
llvm-gnatmake --target=aarch64-linux-android library.adb
```

**Pros**: Free, open-source, LLVM ecosystem
**Cons**: Experimental, limited debugging, may require patches

### Option 3: Cross-Compile Manually

**Approach**: Build GCC/GNAT cross-compiler from source

**Steps**:
1. Build GCC cross-compiler for Android targets
2. Build GNAT on top of GCC cross-compiler
3. Package Ada runtime for Android

**Time Required**: 1-2 weeks of expert work
**Difficulty**: Expert level
**Reliability**: Variable

## Hybrid Workflow (Current Best Approach)

### Strategy
1. **Develop in Ada** on Linux (authoritative source)
2. **Auto-generate C** equivalent for Android
3. **Maintain both** versions in sync

### Implementation

See `sync_ada_to_c.py` script that:
- Parses Ada source
- Generates equivalent C functions
- Maintains interface compatibility
- Handles error conditions consistently

### Verification
- Unit tests verify both Ada and C produce identical results
- CI/CD pipeline ensures synchronization
- Documentation tracks which functions are Ada vs C

## Comparison

| Approach | Cost | Time | Reliability | Maintenance |
|----------|------|------|-------------|-------------|
| GNAT Pro | High ($$$) | Low (days) | Excellent | Low |
| GNAT LLVM | Free | Medium (weeks) | Good | Medium |
| Manual Cross | Free | High (weeks/months) | Variable | High |
| Hybrid C | Free | Low (days) | Good | Low |

## Recommendation

**For Production**: AdaCore GNAT Pro (if budget allows)
**For Prototyping**: Current hybrid C approach
**For Learning**: GNAT LLVM experimentation

## Current Implementation Details

The Android libraries are built from:
- **Source**: `ada_lib/ada_math_android.c`
- **Interface**: Identical to Ada (`ada_add`, `ada_multiply`, etc.)
- **Behavior**: Mimics Ada error handling
- **Performance**: Equivalent for basic math operations

To switch to true Ada:
1. Choose an option above
2. Replace C source with Ada compilation
3. Update `build_android.sh` to use Ada compiler
4. Test on Android devices

The FFI interface and Flutter code remain unchanged.