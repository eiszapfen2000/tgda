#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface ODSelectionGroup : NPObject
{
    FVector2 * position; //upper left
    FVector2 * size;
    FVector2 * itemSize;
    FVector2 * spacing;

    Int32 rows;
    Int32 columns;
    Int32 activeItem;
    id selectionTexture;

    NSMutableArray * textures;

    id effect;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (Int32) activeItem;
- (FVector2) position;
- (FVector2) itemSize;
- (void) setPosition:(FVector2)newPosition;
- (void) setItemSize:(FVector2)newItemSize;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) update:(Float)frameTime;
- (void) render;

@end
