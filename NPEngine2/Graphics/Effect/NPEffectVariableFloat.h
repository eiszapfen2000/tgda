#import "Core/Basics/NpTypes.h"
#import "Core/Math/FVector.h"
#import "NPEffectVariableUniform.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableFloat : NPEffectVariableUniform
{
    Float value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (Float) value;
- (void) setValue:(Float)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat2 : NPEffectVariableUniform
{
    FVector2 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector2) value;
- (void) setValue:(FVector2)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat3 : NPEffectVariableUniform
{
    FVector3 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector3) value;
- (void) setValue:(FVector3)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat4 : NPEffectVariableUniform
{
    FVector4 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector4) value;
- (void) setValue:(FVector4)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

