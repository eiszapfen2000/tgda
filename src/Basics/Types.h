#ifndef _TYPES_H_
#define _TYPES_H_

typedef unsigned int UInt32;
typedef signed int Int32;
typedef Int32 Int;

typedef unsigned short UInt16;
typedef signed short Int16;

#ifdef _NP_64BIT_SYSTEM_
typedef signed long Int64;
typedef unsigned long UInt64;
#else
typedef signed long long Int64;
typedef unsigned long long UInt64;
#endif

typedef float Float;
typedef double Double;

#ifdef _32BIT_REAL_
typedef Float Real;
#else
typedef Double Real;
#endif

#define NP_INT32_MIN       ((Int32) -2147483648L)
#define NP_INT32_MAX       ((Int32) +2147483647L)
#define NP_UINT32_MAX      ((UInt32) 0xffffffffL)

#endif
