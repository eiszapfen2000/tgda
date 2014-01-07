#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat4;

@interface ODButtonItem : ODMenuItem
{
    BOOL active;
    FRectangle pixelCenterGeometry;
    NSString * label;

    NPEffectTechnique * technique;
    NPEffectVariableFloat4 * color;
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
