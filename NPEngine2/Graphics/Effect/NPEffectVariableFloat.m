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

- (Float) value
{
    return value;
}

- (void) setValue:(Float)newValue
{
    value = newValue;
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

- (void) setValue:(FVector2)newValue
{
    value = newValue;
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

- (void) setValue:(FVector3)newValue
{
    value = newValue;
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

- (void) setValue:(FVector4)newValue
{
    value = newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform4f([ variable location ], value.x, value.y, value.z, value.w );
}

@end

