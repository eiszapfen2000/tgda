#ifndef _NP_BASICS_TYPES_H_
#define _NP_BASICS_TYPES_H_

#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include <float.h>

#ifdef _NP_64BIT_SYSTEM_
#define NP_64BIT_LONG
#else
#define NP_32BIT_LONG
#endif

typedef uint16_t Half;
typedef float Float;
typedef double Double;

#define NP_NONE  -1

#endif //_NP_BASICS_TYPES_H_
