#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define OD_CHECKBOX_ALIGNMENT_LEFT   0
#define OD_CHECKBOX_ALIGNMENT_BOTTOM 1
#define OD_CHECKBOX_ALIGNMENT_RIGHT  2
#define OD_CHECKBOX_ALIGNMENT_TOP    3

@interface ODCheckBoxItem : NPObject
{
    FVector2 * position; //upper left
    FVector2 * size; //upper left

    NpState alignment;

    id uncheckedTexture;
    id checkedTexture;
    id effect;

    BOOL checked;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (BOOL) checked;
- (FVector2) position;
- (FVector2) size;

- (void) setChecked:(BOOL)newChecked;
- (void) setPosition:(FVector2)newPosition;
- (void) setSize:(FVector2)newSize;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) update:(Float)frameTime;
- (void) render;

@end
