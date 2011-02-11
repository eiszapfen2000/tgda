#ifndef _NP_BASICS_MEMORY_H_
#define _NP_BASICS_MEMORY_H_

#include <string.h>
#include <stdlib.h>

#ifndef ALLOC
#define ALLOC(_struct)  ((_struct*)malloc(sizeof(_struct)))
#endif

#ifndef ALLOC_ARRAY
#define ALLOC_ARRAY(_struct,_number)    ((_struct*) malloc(sizeof(_struct) * (_number)))
#endif

#ifndef COPY_ARRAY
#define COPY_ARRAY(_source,_target,_struct,_number)    memcpy(_target,_source,sizeof(_struct) * (_number))
#endif

#ifndef REALLOC_ARRAY
#define REALLOC_ARRAY(_source,_struct,_number)    ((_struct*) realloc(_source, sizeof(_struct) * (_number)))
#endif


#define FREE(_pointer)		do {void* _ptr = (void*)(_pointer); free(_ptr); _ptr=NULL; } while (0)
#define SAFE_FREE(_pointer) { if ( (_pointer) != NULL ) FREE((_pointer)); }

#endif //_NP_BASICS_MEMORY_H_
