#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableSampler.h"

@implementation NPEffectVariableSampler

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
          texelUnit:(uint32_t)newTexelUnit
{
    self = [ super initWithName:newName
                   variableType:NpEffectVariableTypeSampler ];

    texelUnit = newTexelUnit;

    return self;
}

- (uint32_t) texelUnit
{
    return texelUnit;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    GLint location = [ variable location ];
    glUniform1i(location, (GLint)texelUnit);
}

@end
