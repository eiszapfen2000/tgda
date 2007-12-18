#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "Core/Math/FVector.h"
#import "NPVertexBuffer.h"

@interface NPSUXModelLod : NPObject
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

- (void) loadFromFile:(NPFile *)file;

@end
