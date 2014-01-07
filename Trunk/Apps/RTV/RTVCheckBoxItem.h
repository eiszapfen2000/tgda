#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define RTV_CHECKBOX_TEXT_ALIGNMENT_LEFT  0
#define RTV_CHECKBOX_TEXT_ALIGNMENT_RIGHT 1

@interface RTVCheckBoxItem : NPObject
{
    FVector2 * position; //upper left
    FVector2 * size; //upper left

    NSString * text;
    NpState textAlignment;

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
- (NSString *) text;
- (void) setChecked:(BOOL)newChecked;
- (void) setPosition:(FVector2)newPosition;
- (void) setSize:(FVector2)newSize;
- (void) setText:(NSString *)newText;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) update:(Float)frameTime;
- (void) render;

@end
