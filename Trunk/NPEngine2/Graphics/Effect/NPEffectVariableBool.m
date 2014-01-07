#import "NPEffectTechniqueVariable.h"
#import "NPEffectVariableBool.h"

@implementation NPEffectVariableBool

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat ];

    value = 0;

    return self;
}

- (int32_t) value
{
    return value;
}

- (void) setValue:(int32_t)newValue
{
    value = newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform1i([ variable location ], value );
}

@end

@implementation NPEffectVariableBool2

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat2 ];

    value.x = value.y = 0;

    return self;
}

- (IVector2) value
{
    return value;
}

- (void) setValue:(IVector2)newValue
{
    value = newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform2i([ variable location ], value.x, value.y );
}

@end

@implementation NPEffectVariableBool3

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat3 ];

    value.x = value.y = value.z = 0;

    return self;
}

- (IVector3) value
{
    return value;
}

- (void) setValue:(IVector3)newValue
{
    value = newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform3i([ variable location ], value.x, value.y, value.z );
}

@end

@implementation NPEffectVariableBool4

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName uniformType:NpUniformFloat4 ];

    value.x = value.y = value.z = value.w = 0;

    return self;
}

- (IVector4) value
{
    return value;
}

- (void) setValue:(IVector4)newValue
{
    value = newValue;
}

- (void) activate:(NPEffectTechniqueVariable *)variable
{
    glUniform4i([ variable location ], value.x, value.y, value.z, value.w );
}

@end

