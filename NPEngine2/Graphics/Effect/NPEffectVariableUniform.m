#import "NPEffectVariableUniform.h"

@implementation NPEffectVariableUniform

- (id) init
{
    [ self subclassResponsibility:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self subclassResponsibility:_cmd ];
    return nil;
}

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

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    [ self subclassResponsibility:_cmd ];
}

@end

