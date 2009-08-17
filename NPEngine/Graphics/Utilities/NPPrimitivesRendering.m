#import "Graphics/npgl.h"
#import "NPPrimitivesRendering.h"

@implementation NPPrimitivesRendering

+ (void) renderFRectangle:(FRectangle *)rectangle
{
    FRectangle texCoords = { {0.0f, 0.0f}, {1.0f, 1.0f} };

    [ NPPrimitivesRendering renderFRectangleGeometry:rectangle withTexCoords:&texCoords ];
}

+ (void) renderFRectangleGeometry:(FRectangle *)geometry withTexCoords:(FRectangle *)texCoords
{
    glBegin(GL_QUADS);

        glTexCoord2f(texCoords->min.x, texCoords->min.y);
        glVertex4f(geometry->min.x, geometry->min.y, 0.0f, 1.0f);

        glTexCoord2f(texCoords->max.x, texCoords->min.y);
        glVertex4f(geometry->max.x, geometry->min.y, 0.0f, 1.0f);

        glTexCoord2f(texCoords->max.x, texCoords->max.y);
        glVertex4f(geometry->max.x, geometry->max.y, 0.0f, 1.0f);

        glTexCoord2f(texCoords->min.x, texCoords->max.y);
        glVertex4f(geometry->min.x, geometry->max.y, 0.0f, 1.0f);

    glEnd();
}

@end
