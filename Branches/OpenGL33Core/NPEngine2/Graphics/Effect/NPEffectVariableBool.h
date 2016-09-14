#import "Core/Basics/NpTypes.h"
#import "Core/Math/IVector.h"
#import "NPEffectVariableUniform.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableBool : NPEffectVariableUniform
{
    int32_t value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (int32_t) value;
- (void) setValue:(int32_t)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableBool2 : NPEffectVariableUniform
{
    IVector2 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (IVector2) value;
- (void) setValue:(IVector2)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableBool3 : NPEffectVariableUniform
{
    IVector3 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (IVector3) value;
- (void) setValue:(IVector3)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableBool4 : NPEffectVariableUniform
{
    IVector4 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (IVector4) value;
- (void) setValue:(IVector4)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

