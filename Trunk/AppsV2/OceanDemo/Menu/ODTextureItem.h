#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat2;
@class NPEffectVariableFloat4;
@class NPTexture2D;

@interface ODTextureItem : ODMenuItem
{
    FRectangle pixelCenterGeometry;
    NSString * label;
    FVector4 channels;

    NPEffectTechnique * colorTechnique;
    NPEffectTechnique * textureRangeTechnique;
    NPEffectVariableFloat4 * color;
    NPEffectVariableFloat2 * range;
    NPEffectVariableFloat4 * mask;
    NPTexture2D * texture;

    OdTargetProperty visibleTarget;
    BOOL visible;
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

@end
