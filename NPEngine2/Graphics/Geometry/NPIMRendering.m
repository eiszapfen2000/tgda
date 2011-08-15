#import "GL/glew.h"
#import "NPIMRendering.h"

@implementation NPIMRendering

+ (void) renderFRectangle:(const FRectangle)rectangle
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertex2f(rectangle.min.x, rectangle.min.y);
        glVertex2f(rectangle.max.x, rectangle.min.y);
        glVertex2f(rectangle.max.x, rectangle.max.y);
        glVertex2f(rectangle.min.x, rectangle.max.y);
    glEnd();
}

+ (void) renderFRectangle:(const FRectangle)rectangle
                texCoords:(const FRectangle)texCoords
            primitiveType:(const NpPrimitveType)primitiveType
{
    glBegin(primitiveType);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.min.y);
        glVertex2f(rectangle.min.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.min.y);
        glVertex2f(rectangle.max.x, rectangle.min.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.max.x, texCoords.max.y);
        glVertex2f(rectangle.max.x, rectangle.max.y);
        glVertexAttrib2f(NpVertexStreamTexCoords0, texCoords.min.x, texCoords.max.y);
        glVertex2f(rectangle.min.x, rectangle.max.y);
    glEnd();
}

@end
