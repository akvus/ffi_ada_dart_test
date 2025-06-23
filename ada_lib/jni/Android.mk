# Android.mk for Ada Math Library
# This builds a native library for Android using ndk-build

LOCAL_PATH := $(call my-dir)

# Clear variables
include $(CLEAR_VARS)

# Module name (will create libada_math.so)
LOCAL_MODULE := ada_math

# C source files (since NDK doesn't support Ada directly)
LOCAL_SRC_FILES := ada_math_ndk.c

# Compiler flags
LOCAL_CFLAGS := -O2 -Wall -fPIC
LOCAL_LDLIBS := -lm -llog

# Export symbols for FFI
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)

# Build shared library
include $(BUILD_SHARED_LIBRARY)