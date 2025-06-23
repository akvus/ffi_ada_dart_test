# Application.mk for Ada Math Library
# Defines build parameters for all ABIs

# Target all major Android architectures
APP_ABI := arm64-v8a armeabi-v7a x86_64 x86

# Minimum Android API level
APP_PLATFORM := android-21

# STL to use
APP_STL := c++_static

# Optimization
APP_OPTIM := release

# Enable C++ exceptions (if needed)
APP_CPPFLAGS := -std=c++11

# Debug info
APP_DEBUG := false