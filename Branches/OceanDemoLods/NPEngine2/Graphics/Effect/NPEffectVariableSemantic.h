#import "NPEffectVariable.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableSemantic : NPEffectVariable
{
    NpEffectSemantic semantic;
}

- (id) initWithName:(NSString *)newName
           semantic:(NpEffectSemantic)newSemantic
                   ;

- (NpEffectSemantic) semantic;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end
