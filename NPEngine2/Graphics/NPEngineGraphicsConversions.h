#ifndef NPENGINEGRAPHICSCONVERSIONS_H_
#define NPENGINEGRAPHICSCONVERSIONS_H_

#include <Foundation/NSObjCRuntime.h>
#include "GL/glew.h"

BOOL NSUIntegerToGLsizei(const NSUInteger uint, GLsizei* sizei);
BOOL NSUIntegerToGLsizeiptr(const NSUInteger uint, GLsizeiptr* sizeiptr);
BOOL NSUIntegerToGLintptr(const NSUInteger uint, GLintptr* intptr);

#endif

