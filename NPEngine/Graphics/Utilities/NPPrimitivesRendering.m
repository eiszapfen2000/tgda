#import "Graphics/npgl.h"
#import "NPPrimitivesRendering.h"

@implementation NPPrimitivesRendering

+ (void) renderFRectangle:(FRectangle *)rectangle
{
    glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 0.0f);
        glVertex4f(rectangle->min.x, rectangle->min.y, 0.0f, 1.0f);
        glTexCoord2f(1.0f, 0.0f);
        glVertex4f(rectangle->max.x, rectangle->min.y, 0.0f, 1.0f);
        glTexCoord2f(1.0f, 1.0f);
        glVertex4f(rectangle->max.x, rectangle->max.y, 0.0f, 1.0f);
        glTexCoord2f(0.0f, 1.0f);
        glVertex4f(rectangle->min.x, rectangle->max.y, 0.0f, 1.0f);
    glEnd();
}

@end
