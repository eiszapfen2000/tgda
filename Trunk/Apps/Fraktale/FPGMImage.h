#import "Core/NPObject/NPObject.h"

@interface FPGMImage : NPObject
{
    Long width;
    Long height;
    Byte * imageData;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (Long) width;
- (Long) height;
- (Byte *) imageData;

- (BOOL) loadFromPath:(NSString *)path;

@end
