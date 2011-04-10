#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariable : NPObject
{
    NpEffectVariableType variableType;
}

- (id) initWithName:(NSString *)newName
       variableType:(NpEffectVariableType)newVariableType
                   ;

- (NpEffectVariableType) variableType;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end
