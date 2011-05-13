#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;
@class NPSUX2MaterialInstance;

@interface NPSUX2Model : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NSMutableArray * lods;
    NSMutableArray * materials;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPSUX2MaterialInstance *) materialInstanceAtIndex:(const NSUInteger)index;

- (void) render;
- (void) renderLOD:(uint32_t)index;

@end
