# Android Setup Guide for Ada-Flutter FFI

This guide explains how to prepare and build the Ada mathematical library for use in Flutter Android applications via Dart FFI.

## Current Status

✅ **Completed:**
- Ada library compiled for x86_64 Linux
- C wrapper and header files created
- Flutter FFI bindings implemented
- Calculator app using Ada functions (works on Linux)
- Android JNI directory structure created

❌ **Pending:**
- Ada library compilation for Android architectures
- Android NDK cross-compilation setup

## Prerequisites

### 1. Android NDK
Install Android NDK (recommended version 25.x or later):
```bash
# Via Android Studio SDK Manager, or:
sdkmanager "ndk;25.2.9519653"
```

Set environment variable:
```bash
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/25.2.9519653
```

### 2. GNAT Compiler with Android Support

**Option A: AdaCore GNAT Pro (Commercial)**
- Contact AdaCore for GNAT Pro with Android cross-compilation support
- Includes pre-built Android runtime libraries
- Full support for all Android ABIs

**Option B: Build GNAT Cross-Compiler (Advanced)**
- Build GCC/GNAT from source with Android target
- Requires significant expertise and time
- See: https://gcc.gnu.org/wiki/Building_Cross_Toolchains_with_gcc

**Option C: Alternative Approaches**
1. **C Bridge Approach**: Rewrite critical Ada functions in C
2. **JNI Wrapper**: Create Java/Kotlin wrapper that calls Ada via JNI
3. **WebAssembly**: Compile Ada to WASM and use in Flutter Web

## Build Instructions

### Step 1: Prepare the Environment
```bash
cd ada_lib/
export ANDROID_NDK_HOME=/path/to/android-ndk
```

### Step 2: Run the Build Script
```bash
./build_android.sh
```

Note: The current `build_android.sh` is a template. You'll need to modify it based on your GNAT installation.

### Step 3: Expected Output
After successful compilation, you should have:
```
flutter_proj/android/app/src/main/jniLibs/
├── armeabi-v7a/
│   └── libada_math.so
├── arm64-v8a/
│   └── libada_math.so
├── x86/
│   └── libada_math.so
└── x86_64/
    └── libada_math.so
```

## Architecture-Specific Builds

### ARM 32-bit (armeabi-v7a)
- Target triple: `arm-linux-androideabi`
- Min SDK: 16
- Used by: Older Android devices

### ARM 64-bit (arm64-v8a)
- Target triple: `aarch64-linux-android`
- Min SDK: 21
- Used by: Modern Android devices (most common)

### x86 32-bit
- Target triple: `i686-linux-android`
- Min SDK: 16
- Used by: Android emulators (older)

### x86_64
- Target triple: `x86_64-linux-android`
- Min SDK: 21
- Used by: Android emulators (modern)

## Gradle Configuration

The Flutter Android build should automatically include libraries from `jniLibs/`. If needed, verify in `android/app/build.gradle`:

```gradle
android {
    sourceSets {
        main {
            jniLibs.srcDirs = ['src/main/jniLibs']
        }
    }
}
```

## Testing

1. **Test on Emulator**:
   ```bash
   flutter run
   ```

2. **Test on Device**:
   ```bash
   flutter run -d <device-id>
   ```

3. **Verify Library Loading**:
   Check logcat for library loading messages:
   ```bash
   adb logcat | grep -i "ada_math"
   ```

## Troubleshooting

### Library Not Found
- Ensure .so files are in correct ABI directories
- Check that library names match (libada_math.so)
- Verify file permissions (should be readable)

### Unsatisfied Link Error
- Check that all Ada runtime dependencies are included
- May need to bundle libgnat.so and other Ada runtime libraries
- Use `readelf -d libada_math.so` to check dependencies

### Architecture Mismatch
- Ensure you've built for all target architectures
- Use `file libada_math.so` to verify architecture
- Check device ABI with `adb shell getprop ro.product.cpu.abi`

## Alternative: C Implementation

If Ada cross-compilation proves difficult, consider implementing the math functions in C:

```c
// ada_math_android.c
#include "ada_math.h"

float ada_add(float a, float b) { return a + b; }
float ada_subtract(float a, float b) { return a - b; }
// ... implement other functions

// Compile with NDK:
// $NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang \
//   --target=aarch64-linux-android21 -shared -o libada_math.so ada_math_android.c
```

## Resources

- [Android NDK Documentation](https://developer.android.com/ndk)
- [Dart FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [AdaCore GNAT Pro](https://www.adacore.com/gnatpro)
- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels) (alternative to FFI)