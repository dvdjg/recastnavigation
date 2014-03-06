#ifndef DETOURMATH_H
#define DETOURMATH_H

/**
@defgroup detour Detour

Members in this module are wrappers around the standard math library

*/

#include <math.h>

#define dtMathFabs(x) fabs(x)
#define dtMathSqrtf(x) sqrt(x)
#define dtMathFloorf(x) floor(x)
#define dtMathCeilf(x) ceil(x)
#define dtMathCosf(x) cos(x)
#define dtMathSinf(x) sin(x)
#define dtMathAtan2f(y, x) atan2(y, x)

#endif
