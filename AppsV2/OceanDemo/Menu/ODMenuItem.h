#import "Core/Math/FRectangle.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSDictionary;
@class NSError;
@class ODMenu;

@interface ODMenuItem : NPObject
{
    ODMenu * menu;
    NpOrthographicAlignment alignment;
    FRectangle geometry;
    FRectangle alignedGeometry;
    uint32_t textSize;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
                   ;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
                           ;

- (BOOL) isHit:(const FVector2)mousePosition;
- (void) onClick:(const FVector2)mousePosition;
- (void) update:(const float)frameTime;
- (void) render;

@end
