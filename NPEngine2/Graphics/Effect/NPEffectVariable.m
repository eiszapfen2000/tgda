#import "NPEffectVariable.h"

@implementation NPEffectVariable

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
       variableType:(NpEffectVariableType)newVariableType
{
    self = [ super initWithName:newName parent:newParent ];

    variableType = newVariableType;

    return self;
}

@end
