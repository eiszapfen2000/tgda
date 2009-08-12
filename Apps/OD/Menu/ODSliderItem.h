#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface ODSliderItem : NPObject
{
    NSString * description;

    FRectangle * lineGeometry;
    FRectangle * headGeometry;

    NpState alignment;

    id lineTexture;
    id headTexture;
    id effect;

    Float minimumValue;
    Float maximumValue;

    id target;
    unsigned int size;
    int offset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;

- (Float) scaledValue;

- (BOOL) mouseHit:(FVector2)mousePosition;
- (void) onClick:(FVector2)mousePosition;

- (void) update:(Float)frameTime;
- (void) render;

@end
