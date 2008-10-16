#import "Core/NPObject/NPObject.h"
#import "NPPResource.h"

@interface NPResource : NPObject < NPPResource >
{
    NSString * fileName;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setFileName:(NSString *)newFileName;
- (NSString *)fileName;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) ready;

@end
