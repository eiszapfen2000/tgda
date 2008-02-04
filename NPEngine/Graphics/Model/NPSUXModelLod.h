#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPVertexBuffer;

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

@end
