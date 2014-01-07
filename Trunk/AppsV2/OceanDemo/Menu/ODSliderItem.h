#import "ODMenuItem.h"

typedef enum OdSliderItemDirection
{
    OdHorizontalSliderItem = 0,
    OdVerticalSliderItem = 1
}
OdSliderItemDirection;

@class NPEffectTechnique;
@class NPEffectVariableFloat4;

@interface ODSliderItem : ODMenuItem
{
    NSString * label;
    FVector2 lineSize;
    FVector2 headSize;
    FVector2 headOffset;
    FRectangle lineGeometry;
    FRectangle alignedLineGeometry;
    FRectangle alignedHeadGeometry;
    OdSliderItemDirection direction;

    float minimumValue;
    float maximumValue;

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
