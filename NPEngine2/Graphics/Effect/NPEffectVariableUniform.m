#import "NPEffectVariableUniform.h"

@implementation NPEffectVariableUniform

- (id) initWithName:(NSString *)newName
        uniformType:(NpUniformType)newUniformType
{
    self = [ super initWithName:newName
                   variableType:NpEffectVariableTypeUniform ];

    uniformType = newUniformType;

    return self;
}

- (NpUniformType) uniformType
{
    return uniformType;
}

@end

