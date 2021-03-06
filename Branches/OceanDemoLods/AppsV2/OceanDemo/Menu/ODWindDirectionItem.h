#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat4;
@class NPVertexArray;

@interface ODWindDirectionItem : ODMenuItem
{
    FRectangle pixelCenterGeometry;
    NSString * label;

    FMatrix4 translation;
    Vector2 windDirection;
    float radius;
    NPVertexArray* circleGeometry;
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
