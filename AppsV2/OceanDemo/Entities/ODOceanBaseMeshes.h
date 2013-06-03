#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NSMutableArray;

@interface ODOceanBaseMeshes : NPObject
{
    NSMutableArray * meshes;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) generateWithResolutions:(const int32_t *)resolutions
             numberOfResolutions:(int32_t)numberOfResolutions
                                ;

- (void) updateIndex:(NSUInteger)index withData:(NSData *)data;

- (void) renderMeshAtIndex:(NSUInteger)index;

@end

