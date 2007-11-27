#ifndef _NP_BASICS_MEMORY_H_
#define _NP_BASICS_MEMORY_H_

#include <stdlib.h>

#ifndef ALLOC
#define ALLOC(_struct)  ((_struct *)malloc(sizeof(_struct)))
#endif

#ifndef ALLOC_ARRAY
#define ALLOC_ARRAY(_struct,_number)    ((_struct *) malloc(sizeof(_struct) * (_number)))
#endif

#endif //_NP_BASICS_MEMORY_H_
