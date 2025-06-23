/*
 * Ada Math Library - NDK Implementation
 * This C implementation provides the same interface as the Ada library
 * and can be built with ndk-build for all Android ABIs
 */

#include <math.h>
#include <android/log.h>

#define LOG_TAG "AdaMath"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// Math function implementations that match Ada behavior

float ada_add(float a, float b) {
    LOGI("ada_add(%.2f, %.2f)", a, b);
    return a + b;
}

float ada_subtract(float a, float b) {
    LOGI("ada_subtract(%.2f, %.2f)", a, b);
    return a - b;
}

float ada_multiply(float a, float b) {
    LOGI("ada_multiply(%.2f, %.2f)", a, b);
    return a * b;
}

float ada_divide(float a, float b) {
    LOGI("ada_divide(%.2f, %.2f)", a, b);
    if (b == 0.0f) {
        LOGI("Division by zero detected");
        return NAN;  // Ada would raise Constraint_Error
    }
    return a / b;
}

float ada_sqrt(float x) {
    LOGI("ada_sqrt(%.2f)", x);
    if (x < 0.0f) {
        LOGI("Square root of negative number");
        return NAN;  // Ada would raise Constraint_Error
    }
    return sqrtf(x);
}

float ada_power(float base, float exponent) {
    LOGI("ada_power(%.2f, %.2f)", base, exponent);
    return powf(base, exponent);
}

float ada_abs(float x) {
    LOGI("ada_abs(%.2f)", x);
    return fabsf(x);
}

float ada_max(float a, float b) {
    LOGI("ada_max(%.2f, %.2f)", a, b);
    return fmaxf(a, b);
}

float ada_min(float a, float b) {
    LOGI("ada_min(%.2f, %.2f)", a, b);
    return fminf(a, b);
}

// Optional: Initialization function for logging
void ada_math_init() {
    LOGI("Ada Math Library initialized (NDK build)");
}