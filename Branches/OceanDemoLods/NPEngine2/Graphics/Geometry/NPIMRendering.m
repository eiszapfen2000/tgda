#import "GL/glew.h"
#import "NPIMRendering.h"

@implementation NPIMRendering

+ (void) renderFRectangle:(const FRectangle)rectangle
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.min.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.max.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.max.x, rectangle.max.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.min.x, rectangle.max.y);
    glEnd();
}

+ (void) renderIRectangle:(const IRectangle)rectangle
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.min.x, rectangle.min.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.max.x, rectangle.min.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.max.x, rectangle.max.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.min.x, rectangle.max.y);
    glEnd();
}

+ (void) renderFTriangle:(const FTriangle)triangle
           primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttrib2f(NpVertexStreamPositions, triangle.a.x, triangle.a.y);
        glVertexAttrib2f(NpVertexStreamPositions, triangle.b.x, triangle.b.y);
        glVertexAttrib2f(NpVertexStreamPositions, triangle.c.x, triangle.c.y);
    glEnd();
}

+ (void) renderFRectangle:(const FRectangle)rectangle
                texCoords:(const FRectangle)texCoords
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.min.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.min.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.min.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.max.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.max.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.max.x, rectangle.max.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.max.y);
        glVertexAttrib2f(NpVertexStreamPositions, rectangle.min.x, rectangle.max.y);
    glEnd();
}

+ (void) renderIRectangle:(const IRectangle)rectangle
                texCoords:(const IRectangle)texCoords
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttribI2i(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.min.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.min.x, rectangle.min.y);
        glVertexAttribI2i(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.min.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.max.x, rectangle.min.y);
        glVertexAttribI2i(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.max.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.max.x, rectangle.max.y);
        glVertexAttribI2i(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.max.y);
        glVertexAttribI2i(NpVertexStreamPositions, rectangle.min.x, rectangle.max.y);
    glEnd();
}

+ (void) renderFTriangle:(const FTriangle)triangle
               texCoords:(const FTriangle)texCoords
           primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.a.x, texCoords.a.y);
        glVertexAttrib2f(NpVertexStreamPositions,  triangle.a.x,  triangle.a.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.b.x, texCoords.b.y);
        glVertexAttrib2f(NpVertexStreamPositions,  triangle.b.x,  triangle.b.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.c.x, texCoords.c.y);
        glVertexAttrib2f(NpVertexStreamPositions,  triangle.c.x,  triangle.c.y);
    glEnd();
}

@end
