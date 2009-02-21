#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"

@class NPEffect;
@class NPTexture;

@interface NPFont : NPObject
{
    Float * characterWidths;
    NPEffect * effect;
    NPTexture * texture;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NPEffect *) effect;
- (NPTexture *) texture;
- (void) setEffect:(NPEffect *)newEffect;

- (BOOL) loadFromPath:(NSString *)path;

- (void) renderString:(NSString *)string atPosition:(FVector2 *)position withSize:(Float)size;
- (void) renderString:(NSString *)string
           atPosition:(FVector2 *)position
        withAlignment:(NpState)alignment
                 size:(Float)size
                color:(FVector4 *)color
                     ;

@end
