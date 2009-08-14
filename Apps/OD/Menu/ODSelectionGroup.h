#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPEffect;
@class NPTexture;

@interface ODSelectionGroup : NPObject
{
    NSString * description;

    NpState alignment;

    FRectangle * boundingRectangle;
    FRectangle * items;

    Int32 rows;
    Int32 columns;
    Int32 activeItem;

    NPTexture * selectionTexture;
    NSMutableArray * textures;

    NPEffect * effect;

    id target;
    unsigned int size;
    int offset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (Int32) activeItem;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) render;

@end
