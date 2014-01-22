#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat2;
@class NPEffectVariableFloat4;
@class NPTexture2D;

@interface ODWaterColorItem : ODMenuItem
{
    FRectangle pixelCenterGeometry;
    NSString * label;
    FVector4 channels;

    NPEffectTechnique * colorTechnique;
    NPEffectTechnique * textureTechnique;
    NPEffectVariableFloat4 * color;
    NPTexture2D * texture;

    FVector2 coordinate;
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
