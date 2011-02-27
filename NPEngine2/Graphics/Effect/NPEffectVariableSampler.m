#import "NPEffectVariableSampler.h"

@implementation NPEffectVariableSampler

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName
                         parent:newParent
                   variableType:NpEffectVariableTypeSampler ];

    return self;
}

@end
