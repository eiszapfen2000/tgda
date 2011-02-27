#import "NPEffectVariableSampler.h"

@implementation NPEffectVariableSampler

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName
                   variableType:NpEffectVariableTypeSampler ];

    texelUnit = UINT_MAX;

    return self;
}

@end
