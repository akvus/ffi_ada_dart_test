#include "ada_math.h"
#include <math.h>

// C implementation of Ada math functions for Android
// This provides the same interface as the Ada library but uses standard C math

float ada_add(float a, float b) {
    return a + b;
}

float ada_subtract(float a, float b) {
    return a - b;
}

float ada_multiply(float a, float b) {
    return a * b;
}

float ada_divide(float a, float b) {
    // Handle division by zero the same way Ada would
    if (b == 0.0f) {
        // In Ada, this would raise Constraint_Error
        // For Android, we'll return NaN or handle gracefully
        return NAN;
    }
    return a / b;
}

float ada_sqrt(float x) {
    // Handle negative input like Ada would
    if (x < 0.0f) {
        return NAN;  // Ada would raise Argument_Error
    }
    return sqrtf(x);
}

float ada_power(float base, float exponent) {
    return powf(base, exponent);
}

float ada_abs(float x) {
    return fabsf(x);
}

float ada_max(float a, float b) {
    return a > b ? a : b;
}

float ada_min(float a, float b) {
    return a < b ? a : b;
}