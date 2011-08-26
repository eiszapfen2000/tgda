#import "Core/Math/FVector.h"
#import "Core/Math/FRectangle.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSMutableArray;
@class NSMutableDictionary;
@class NPInputAction;
@class NPFont;
@class NPEffect;
@class NPEffectTechnique;

@interface ODMenu : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NSMutableDictionary * textures;
    NSMutableArray * menuItems;

    NPInputAction * menuActivationAction;
    NPInputAction * menuClickAction;
    BOOL menuActive;
    BOOL menuActivating;
    BOOL menuDeactivating;
    float activatingTime;
    float opacity;

    NSMutableArray * fonts;
    NPEffect * effect;
}

+ (FRectangle) alignRectangle:(const FRectangle)rectangle
                withAlignment:(const NpOrthographicAlignment)alignment
                             ;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;

- (NPFont *) fontAtIndex:(const NSUInteger)index;
- (NPFont *) fontForSize:(const uint32_t)size;
- (NPEffect *) effect;
- (NPEffectTechnique *) colorTechnique;
- (NPEffectTechnique *) textureTechnique;
- (NPEffectTechnique *) fontTechnique;
- (float) opacity;

- (void) update:(const float)frameTime;
- (void) render;

@end
