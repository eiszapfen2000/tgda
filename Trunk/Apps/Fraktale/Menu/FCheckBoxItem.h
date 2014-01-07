#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define F_CHECKBOX_ALIGNMENT_LEFT   0
#define F_CHECKBOX_ALIGNMENT_BOTTOM 1
#define F_CHECKBOX_ALIGNMENT_RIGHT  2
#define F_CHECKBOX_ALIGNMENT_TOP    3

@class NPTexture;
@class NPEffect;

@interface FCheckBoxItem : NPObject
{
    NSString * description;

    FRectangle * geometry;

    NpState alignment;

    NPTexture* uncheckedTexture;
    NPTexture* checkedTexture;
    NPEffect* effect;

    BOOL checked;

    id target;
    unsigned int size;
    int offset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (BOOL) checked;
- (void) setChecked:(BOOL)newChecked;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) render;

@end
