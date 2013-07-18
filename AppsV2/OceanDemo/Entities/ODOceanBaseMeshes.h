#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NSMutableArray;
@class ODOceanBaseMesh;

@interface ODOceanBaseMeshes : NPObject
{
    NSMutableArray * meshes;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODOceanBaseMesh *) meshAtIndex:(NSUInteger)index;

- (BOOL) generateWithResolutions:(const int32_t *)resolutions
             numberOfResolutions:(int32_t)numberOfResolutions
                                ;

- (void) updateMeshAtIndex:(NSUInteger)index
                 withYData:(NSData *)yData
          supplementalData:(NSData *)supplementalData
                          ;

- (void) renderMeshAtIndex:(NSUInteger)index;

@end

