#import "Core/Basics/NpTypes.h"
#import "Core/Math/FVector.h"
#import "Core/Math/Vector.h"
#import "Core/Math/FMatrix.h"
#import "Core/Math/Matrix.h"
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

@interface NPEffectVariableMatrix2x2 : NPEffectVariableUniform
{
    FMatrix2 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (const FMatrix2 *) value;
- (void) setFValue:(const FMatrix2 * const)newValue;
- (void) setValue:(const Matrix2 * const)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableMatrix3x3 : NPEffectVariableUniform
{
    FMatrix3 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (const FMatrix3 *) value;
- (void) setFValue:(const FMatrix3 * const)newValue;
- (void) setValue:(const Matrix3 * const)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

@interface NPEffectVariableMatrix4x4 : NPEffectVariableUniform
{
    FMatrix4 value;
}

- (id) init;
- (id) initWithName:(NSString *)newName;

- (const FMatrix4 *) value;
- (void) setFValue:(const FMatrix4 * const)newValue;
- (void) setValue:(const Matrix4 * const)newValue;

- (void) activate:(NPEffectTechniqueVariable *)variable;

@end

