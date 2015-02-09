#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPBufferObject;
@class NPVertexArray;

@interface ODOceanBaseMesh : NPObject
{
    NPBufferObject * xzStream;
    NPBufferObject * yStream;
    NPBufferObject * supplementalStream;
    NPBufferObject * indexStream;
    NPVertexArray * mesh;
    FVector3 center;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (FVector3) center;
- (NPBufferObject *) yStream;
- (NPBufferObject *) supplementalStream;

- (BOOL) generateWithResolution:(int32_t)resolution;

- (void) updateYStream:(NSData *)yData
    supplementalStream:(NSData *)supplementalData
                      ;
- (void) render;

@end
