#import "Core/Math/FRectangle.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

BOOL ODObjCFindVariable(id obj, const char * name,
    NSUInteger * size, ptrdiff_t * offset);

void ODObjCGetVariable(id obj, const ptrdiff_t offset,
    const NSUInteger size, void * data);

void ODObjCSetVariable(id obj, const ptrdiff_t offset,
    const NSUInteger size, const void * data);

@class NSDictionary;
@class NSError;
@class ODMenu;

typedef struct OdTargetProperty
{
    id target;
    NSUInteger size;
    ptrdiff_t offset;
}
OdTargetProperty;

@interface ODMenuItem : NPObject
{
    ODMenu * menu;
    NpOrthographicAlignment alignment;
    FRectangle geometry;
    FRectangle alignedGeometry;
    uint32_t textSize;

    // reflection stuff
    OdTargetProperty targetProperty;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
                   ;

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
                           ;

- (BOOL) isHit:(const FVector2)mousePosition;
- (void) onClick:(const FVector2)mousePosition;
- (void) update:(const float)frameTime;
- (void) render;

@end
