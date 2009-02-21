#import "Core/NPObject/NPObject.h"

@interface NPFontManager : NPObject
{
    NSMutableDictionary * fonts;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) loadFontFromPath:(NSString *)path;
- (id) loadFontFromAbsolutePath:(NSString *)path;

@end
