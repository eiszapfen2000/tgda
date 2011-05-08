#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

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

- (void) render;
- (void) renderLOD:(uint32_t)index;

@end
