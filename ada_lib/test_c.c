#include <stdio.h>

// Declare the Ada functions
extern float ada_add(float a, float b);
extern float ada_subtract(float a, float b);
extern float ada_multiply(float a, float b);
extern float ada_divide(float a, float b);
extern float ada_sqrt(float x);
extern float ada_power(float base, float exponent);
extern float ada_abs(float x);
extern float ada_max(float a, float b);
extern float ada_min(float a, float b);

int main() {
    printf("Testing Ada Library from C\n");
    printf("==========================\n");
    
    printf("ada_add(10.0, 5.0) = %.2f\n", ada_add(10.0f, 5.0f));
    printf("ada_subtract(10.0, 5.0) = %.2f\n", ada_subtract(10.0f, 5.0f));
    printf("ada_multiply(10.0, 5.0) = %.2f\n", ada_multiply(10.0f, 5.0f));
    printf("ada_divide(10.0, 5.0) = %.2f\n", ada_divide(10.0f, 5.0f));
    printf("ada_sqrt(25.0) = %.2f\n", ada_sqrt(25.0f));
    printf("ada_power(2.0, 3.0) = %.2f\n", ada_power(2.0f, 3.0f));
    printf("ada_abs(-15.5) = %.2f\n", ada_abs(-15.5f));
    printf("ada_max(10.0, 20.0) = %.2f\n", ada_max(10.0f, 20.0f));
    printf("ada_min(10.0, 20.0) = %.2f\n", ada_min(10.0f, 20.0f));
    
    return 0;
}