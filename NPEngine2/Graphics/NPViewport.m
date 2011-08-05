#import "GL/glew.h"
#import "NPViewport.h"

@implementation NPViewport

- (id) init
{
    return [ self initWithName:@"Viewport" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    left = right = bottom = top = 0;
    widgetWidth = widgetHeight = 0;
    aspectRatio = 0.0f;

    return self;
}

- (uint32_t) left
{
    return left;
}

- (uint32_t) right
{
    return right;
}

- (uint32_t) bottom
{
    return bottom;
}

- (uint32_t) top
{
    return top;
}

- (uint32_t) width
{
    return right - left;
}

- (uint32_t) height
{
    return top - bottom;
}

- (float) aspectRatio
{
    return aspectRatio;
}

- (uint32_t) widgetWidth
{
    return widgetWidth;
}

- (uint32_t) widgetHeight
{
    return widgetHeight;
}

- (void) setWidgetWidth:(uint32_t)newWidgetWidth
{
    widgetWidth = newWidgetWidth;
}

- (void) setWidgetHeight:(uint32_t)newWidgetHeight
{
    widgetHeight = newWidgetHeight;
}

- (void) reset
{
    [ self setWidth:widgetWidth height:widgetHeight ];
}

- (void) setWidth:(uint32_t)newWidth
           height:(uint32_t)newHeight
{
    left = bottom = 0;
    right = newWidth;
    top   = newHeight;
    aspectRatio = (float)(newWidth) / (float)(newHeight);

    glViewport(0, 0, newWidth, newHeight);
}

- (void) setLeft:(uint32_t)newLeft
           right:(uint32_t)newRight
          bottom:(uint32_t)newBottom
             top:(uint32_t)newTop
{
    left   = newLeft;
    right  = newRight;
    bottom = newBottom;
    top    = newTop;
    aspectRatio = (float)(right - left)/(float)(top - bottom);

    glViewport(left, bottom, right - left, top - bottom);
}

@end
