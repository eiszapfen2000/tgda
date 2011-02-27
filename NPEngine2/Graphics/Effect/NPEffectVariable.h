#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariable : NPObject
{
    NpEffectVariableType variableType;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
       variableType:(NpEffectVariableType)newVariableType
                   ;

- (NpEffectVariableType) variableType;

@end
