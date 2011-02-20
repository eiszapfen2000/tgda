#import "NPEffectVariableSemantic.h"

@implementation NPEffectVariableSemantic

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
           semantic:(NpEffectSemantic)newSemantic
{
    self = [ super initWithName:newName
                         parent:newParent
                   variableType:NpEffectVariableTypeSemantic ];

    semantic = newSemantic;

    return self;
}

@end

