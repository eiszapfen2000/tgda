#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Core/Math/FVector.h"

@class NSMutableArray;
@class NPSUX2VertexBuffer;
@class NPSUX2Model;
@class NPSUX2ModelGroup;

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
    NPSUX2Model * model;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPSUX2VertexBuffer *) vertexBuffer;
- (NPSUX2Model *) model;
- (NPSUX2ModelGroup *) groupAtIndex:(const NSUInteger)index;
- (void) setModel:(NPSUX2Model *)newModel;

- (void) render;

@end
