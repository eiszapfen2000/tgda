#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define RTV_CHECKBOX_TEXT_ALIGNMENT_LEFT  0
#define RTV_CHECKBOX_TEXT_ALIGNMENT_RIGHT 1

@interface RTVSliderItem : NPObject
{
    FVector2 * position; //upper left
    FVector2 * size;
    FVector2 * sliderPosition;
    FVector2 * lineSize;
    FVector2 * headSize;

    id lineTexture;
    id headTexture;

    Float scaleFactor;
    id effect;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (FVector2) position;
- (FVector2) size;
- (Float) scaleFactor;
- (void) setPosition:(FVector2)newPosition;
- (void) setSize:(FVector2)newSize;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) update:(Float)frameTime;
- (void) render;

@end
