#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Core/Math/FVector.h"

@class NSMutableArray;
@class NPSUX2VertexBuffer;

@interface NPSUX2ModelLOD : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    BOOL autoenable;
    float minDistance;
    float maxDistance;

    FVector3 boundingBoxMinimum;
    FVector3 boundingBoxMaximum;
    float boundingSphereRadius;

    NPSUX2VertexBuffer * vertexBuffer;
    NSMutableArray * groups;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPSUX2VertexBuffer *) vertexBuffer;

- (void) render;

@end
