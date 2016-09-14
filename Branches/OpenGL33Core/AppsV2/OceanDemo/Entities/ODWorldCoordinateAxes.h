#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@interface ODWorldCoordinateAxes : NPObject
{
    float axisLength;
    float colorMultiplier;

    GLuint vertexArrayID;
    GLuint vertexStreamID;
    GLuint colorStreamID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (float) axisLength;
- (float) colorMultiplier;
- (void) setAxisLength:(float)newAxisLength;
- (void) setColorMultiplier:(float)newColorMultiplier;

- (void) update:(double)frameTime;
- (void) render;

@end

