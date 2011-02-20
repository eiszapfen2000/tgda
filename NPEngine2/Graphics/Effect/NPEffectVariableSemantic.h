#import "NPEffectVariable.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@interface NPEffectVariableSemantic : NPEffectVariable
{
    NpEffectSemantic semantic;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject>)newParent
           semantic:(NpEffectSemantic)newSemantic
                   ;

@end
