#ifndef _NP_BASICS_TYPES_H_
#define _NP_BASICS_TYPES_H_

typedef unsigned char Byte;
typedef char Char;

typedef unsigned int UInt32;
typedef signed int Int32;
typedef Int32 Int;
typedef UInt32 UInt;

#define NP_INT32_MIN       ((Int32) -2147483648L)
#define NP_INT32_MAX       ((Int32) +2147483647L)
#define NP_UINT32_MAX      ((UInt32) 0xffffffffL)

typedef unsigned short UInt16;
typedef signed short Int16;

#ifdef _NP_64BIT_SYSTEM_
#define NP_64BIT_LONG
typedef signed long Int64;
typedef unsigned long UInt64;
#else
#define NP_32BIT_LONG
typedef signed long long Int64;
typedef unsigned long long UInt64;
#endif

typedef unsigned long ULong;
typedef signed long Long;

typedef UInt16 Half;
typedef float Float;
typedef double Double;

#ifdef _32BIT_REAL_
typedef Float Real;
#else
typedef Double Real;
#endif

typedef Int32 NpState;

#define NP_NONE  -1

#endif //_NP_BASICS_TYPES_H_
