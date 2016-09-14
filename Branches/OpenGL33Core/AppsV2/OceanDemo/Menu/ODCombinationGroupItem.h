#import "Core/Math/FVector.h"
#import "Core/Math/IVector.h"
#import "ODMenuItem.h"

@class NPEffectTechnique;
@class NPEffectVariableFloat4;

@interface ODCombinationGroupItem : ODMenuItem
{
    FVector2 itemSize;
    FVector2 itemSpacing;
    IVector2 layout;
    BOOL * active;
    NSArray * labels;

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
