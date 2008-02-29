#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;

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

- (void) render;

@end
