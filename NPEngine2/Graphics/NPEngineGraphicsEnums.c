#include "NPEngineGraphicsEnums.h"

GLenum getGLComparisonFunction(const NpComparisonFunction comparisonFunction)
{
    GLenum result = GL_NONE;

	switch (comparisonFunction)
	{
	    case NpComparisonNever        : { result = GL_NEVER;   break; }
	    case NpComparisonAlways       : { result = GL_ALWAYS;  break; }
	    case NpComparisonLess         : { result = GL_LESS;    break; }
	    case NpComparisonLessEqual    : { result = GL_LEQUAL;  break; }
	    case NpComparisonEqual        : { result = GL_EQUAL;   break; }
	    case NpComparisonGreaterEqual : { result = GL_GEQUAL;  break; }
	    case NpComparisonGreater      : { result = GL_GREATER; break; }
	}

    return result;
}

GLenum getGLCullface(const NpCullface cullface)
{
    GLenum result = GL_NONE;

    switch (cullface)
    {
        case NpCullfaceFront: { result = GL_FRONT; break; }
        case NpCullfaceBack : { result = GL_BACK;  break; }
    }

    return result;
}

GLenum getGLPolygonFillMode(const NpPolygonFillMode polygonFillMode)
{
    GLenum result = GL_NONE;

    switch (polygonFillMode)
    {
        case NpPolygonFillPoint: { result = GL_POINT; break; }
        case NpPolygonFillLine : { result = GL_LINE;  break; }
        case NpPolygonFillFace : { result = GL_FILL;  break; }
    }

    return result;
}
