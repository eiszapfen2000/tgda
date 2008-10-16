#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"

@class NPFile;
@class NPSUXModel;
@class NPSUXMaterialInstance;

@interface NPSUXModelGroup : NPResource
{
    Int primitiveType;
    Int firstIndex;
    Int lastIndex;
    Int materialInstanceIndex;

    NPSUXModel * model;
    NPSUXMaterialInstance * material;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) saveToFile:(NPFile *)file;
- (void) reset;

- (void) render;

@end
