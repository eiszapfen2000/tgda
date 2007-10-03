#ifndef _NP_MATH_UTILITIES_
#define _NP_MATH_UTILITIES_

#include "Basics/Types.h"

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
