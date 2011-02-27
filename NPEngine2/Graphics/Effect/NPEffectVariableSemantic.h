#import "NPEffectVariable.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableSemantic : NPEffectVariable
{
    NpEffectSemantic semantic;
}

- (id) initWithName:(NSString *)newName;

- (NpEffectSemantic) semantic;
- (void) setSemantic:(NpEffectSemantic)newSemantic;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end
