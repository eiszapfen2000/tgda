#ifndef _NP_MATH_UTILITIES_
#define _NP_MATH_UTILITIES_

#include "Core/Basics/NpTypes.h"
#include "Constants.h"

#define DEGREE_TO_RADIANS(_d)   (_d)*(MATH_DEG_TO_RAD)
#define RADIANS_TO_DEGREE(_r)   (_r)*(MATH_RAD_TO_DEG)

#define IS_INT32_EVEN(_number) \
( div(count, 2).rem == 0 )


#ifdef _NP_64BIT_SYSTEM_

#define IS_INT64_EVEN(_number) \
( ldiv(count, 2).rem == 0 )

#else

#define IS_INT64_EVEN(_number) \
( lldiv(count, 2).rem == 0 )

#endif //_NP_64BIT_SYSTEM_

#endif
