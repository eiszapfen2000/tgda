#import "NPEffectVariable.h"

@interface NPEffectVariableSampler : NPEffectVariable
{
    uint32_t texelUnit;
}

- (id) initWithName:(NSString *)newName
          texelUnit:(uint32_t)newTexelUnit
                   ;

- (uint32_t) texelUnit;

@end
