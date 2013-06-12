#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableFloat.h"

@implementation NPEffectVariableFloat

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat ];

    value = 0.0f;

    return self;
}

- (float) value
{
    return value;
}

- (void) setFValue:(float)newValue
{
    value = newValue;
}

- (void) setValue:(double)newValue
{
    value = (float)newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform1f([ variable location ], value );
}

@end

@implementation NPEffectVariableFloat2

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat2 ];

    value.x = value.y = 0.0f;

    return self;
}

- (FVector2) value
{
    return value;
}

- (void) setFValue:(FVector2)newValue
{
    value = newValue;
}

- (void) setValue:(Vector2)newValue
{
    value.x = (float)newValue.x;
    value.y = (float)newValue.y;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform2f([ variable location ], value.x, value.y );
}

@end

@implementation NPEffectVariableFloat3

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat3 ];

    value.x = value.y = value.z = 0.0f;

    return self;
}

- (FVector3) value
{
    return value;
}

- (void) setFValue:(FVector3)newValue
{
    value = newValue;
}

- (void) setValue:(Vector3)newValue
{
    value.x = (float)newValue.x;
    value.y = (float)newValue.y;
    value.z = (float)newValue.z;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform3f([ variable location ], value.x, value.y, value.z );
}

@end

@implementation NPEffectVariableFloat4

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat4 ];

    value.x = value.y = value.z = value.w = 0.0f;

    return self;
}

- (FVector4) value
{
    return value;
}

- (void) setFValue:(FVector4)newValue
{
    value = newValue;
}

- (void) setValue:(Vector4)newValue
{
    value.x = (float)newValue.x;
    value.y = (float)newValue.y;
    value.z = (float)newValue.z;
    value.w = (float)newValue.w;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform4f([ variable location ], value.x, value.y, value.z, value.w );
}

@end

@implementation NPEffectVariableMatrix2x2

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat4 ];

    fm2_m_set_identity(&value);

    return self;
}

- (const FMatrix2 *) value;
{
    return &value;
}

- (void) setFValue:(const FMatrix2 * const)newValue
{
    value = *newValue;
}

- (void) setValue:(const Matrix2 * const)newValue
{
    fm2_m_init_with_m2(&value, newValue);
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniformMatrix2fv([ variable location ], 1, GL_FALSE, (const GLfloat *)(value.elements));
}

@end

@implementation NPEffectVariableMatrix3x3

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat4 ];

    fm3_m_set_identity(&value);

    return self;
}

- (const FMatrix3 *) value;
{
    return &value;
}

- (void) setFValue:(const FMatrix3 * const)newValue
{
    value = *newValue;
}

- (void) setValue:(const Matrix3 * const)newValue
{
    fm3_m_init_with_m3(&value, newValue);
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniformMatrix3fv([ variable location ], 1, GL_FALSE, (const GLfloat *)(value.elements));
}

@end

@implementation NPEffectVariableMatrix4x4

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat4 ];

    fm4_m_set_identity(&value);

    return self;
}

- (const FMatrix4 *) value;
{
    return &value;
}

- (void) setFValue:(const FMatrix4 * const)newValue
{
    value = *newValue;
}

- (void) setValue:(const Matrix4 * const)newValue
{
    fm4_m_init_with_m4(&value, newValue);
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniformMatrix4fv([ variable location ], 1, GL_FALSE, (const GLfloat *)(value.elements));
}

@end

