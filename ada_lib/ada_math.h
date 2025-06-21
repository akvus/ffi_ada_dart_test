#ifndef ADA_MATH_H
#define ADA_MATH_H

#ifdef __cplusplus
extern "C" {
#endif

// Mathematical operations exported from Ada library
float ada_add(float a, float b);
float ada_subtract(float a, float b);
float ada_multiply(float a, float b);
float ada_divide(float a, float b);
float ada_sqrt(float x);
float ada_power(float base, float exponent);
float ada_abs(float x);
float ada_max(float a, float b);
float ada_min(float a, float b);

#ifdef __cplusplus
}
#endif

#endif // ADA_MATH_H