#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

@interface NPSUX2VertexBuffer : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
