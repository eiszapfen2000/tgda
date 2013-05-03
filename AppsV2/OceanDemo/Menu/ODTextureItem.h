#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat4;
@class NPTexture2D;

@interface ODTextureItem : ODMenuItem
{
    FRectangle pixelCenterGeometry;
    NSString * label;

    NPEffectTechnique * colorTechnique;
    NPEffectTechnique * textureTechnique;
    NPEffectVariableFloat4 * color;
    NPTexture2D * texture;
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
