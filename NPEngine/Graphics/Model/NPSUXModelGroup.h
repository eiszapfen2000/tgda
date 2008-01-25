#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "Core/Resource/NPResource.h"

@interface NPSUXModelGroup : NPResource < NPPResource >
{
    Int primitiveType;
    Int firstIndex;
    Int lastIndex;
    Int materialInstanceIndex;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

@end
