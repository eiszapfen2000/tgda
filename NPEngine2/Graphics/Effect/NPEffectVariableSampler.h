#import "NPEffectVariable.h"

@interface NPEffectVariableSampler : NPEffectVariable
{
    uint32_t texelUnit;
}

- (id) initWithName:(NSString *)newName;

@end
