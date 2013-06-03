#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPBufferObject;
@class NPVertexArray;

@interface ODOceanBaseMesh : NPObject
{
    NPBufferObject * xzStream;
    NPBufferObject * yStream;
    NPBufferObject * indexStream;
    NPVertexArray * mesh;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) generateWithResolution:(int32_t)resolution;

@end
