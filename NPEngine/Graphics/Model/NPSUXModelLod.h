#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPVertexBuffer;
@class NPSUXModelGroup;

@interface NPSUXModelLod : NPResource < NPPResource >
{
    BOOL autoenable;
    Float minDistance;
    Float maxDistance;

    FVector3 * boundingBoxMinimum;
    FVector3 * boundingBoxMaximum;
    Float boundingSphereRadius;

    NPVertexBuffer * vertexBuffer;

    Int groupCount;
    NSMutableArray * groups;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

- (NPVertexBuffer *) vertexBuffer;
- (void) setVertexBuffer:(NPVertexBuffer *)newVertexBuffer;

- (NSArray *) groups;
- (void) addGroup:(NPSUXModelGroup *)newGroup;

- (void) uploadToGL;
- (void) render;

@end
