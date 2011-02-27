#import "NPEffectVariable.h"

@implementation NPEffectVariable

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

@end
