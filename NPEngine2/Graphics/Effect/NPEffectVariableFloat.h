#import "Core/Basics/NpTypes.h"
#import "Core/Math/FVector.h"
#import "Core/Math/Vector.h"
#import "NPEffectVariableUniform.h"

@class NPEffectTechniqueVariable;

@interface NPEffectVariableFloat : NPEffectVariableUniform
{
    float value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (float) value;
- (void) setFValue:(float)newValue;
- (void) setValue:(double)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat2 : NPEffectVariableUniform
{
    FVector2 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector2) value;
- (void) setFValue:(FVector2)newValue;
- (void) setValue:(Vector2)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat3 : NPEffectVariableUniform
{
    FVector3 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector3) value;
- (void) setFValue:(FVector3)newValue;
- (void) setValue:(Vector3)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableFloat4 : NPEffectVariableUniform
{
    FVector4 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (FVector4) value;
- (void) setFValue:(FVector4)newValue;
- (void) setValue:(Vector4)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

