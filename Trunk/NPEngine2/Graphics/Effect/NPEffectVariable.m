#import "NPEffectVariable.h"

@implementation NPEffectVariable

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
       variableType:(NpEffectVariableType)newVariableType
{
    self = [ super initWithName:newName ];

    variableType = newVariableType;

    return self;
}

- (NpEffectVariableType) variableType
{
    return variableType;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    [ self subclassResponsibility:_cmd ];
}

@end
