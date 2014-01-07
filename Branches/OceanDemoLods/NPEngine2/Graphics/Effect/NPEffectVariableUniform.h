#import "NPEffectVariable.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableUniform : NPEffectVariable
{
    NpUniformType uniformType;
}

- (id) initWithName:(NSString *)newName
        uniformType:(NpUniformType)newUniformType
                   ;

- (NpUniformType) uniformType;

@end
