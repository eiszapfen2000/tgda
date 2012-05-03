#include "NPEngineGraphicsConversions.h"

// GLsizeiptr equals int
BOOL NSUIntegerToGLsizei(const NSUInteger uint, GLsizei* sizei)
{
    if (uint > INT_MAX)
    {
        return NO;
    }

    *sizei = (GLsizei)uint;
    return YES;
}

// GLsizeiptr equals ptrdiff_t
BOOL NSUIntegerToGLsizeiptr(const NSUInteger uint, GLsizeiptr* sizeiptr)
{
    if (uint > PTRDIFF_MAX)
    {
        return NO;
    }

    *sizeiptr = (GLsizeiptr)uint;
    return YES;
}

// GLintptr equals ptrdiff_t
BOOL NSUIntegerToGLintptr(const NSUInteger uint, GLintptr* intptr)
{
    if (uint > PTRDIFF_MAX)
    {
        return NO;
    }

    *intptr = (GLintptr)uint;
    return YES;
}




