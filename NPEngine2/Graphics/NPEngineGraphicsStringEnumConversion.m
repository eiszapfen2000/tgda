#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringEnumConversion.h"

@implementation NPEngineGraphicsStringEnumConversion

- (id) init
{
    return [ self initWithName:@"Graphics String Enum Conversion" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    effectVariableTypes = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(effectVariableTypes);

    [ super dealloc ];
}

#define INSERTENUM(_dictionary, _enum, _string) \
    [_dictionary setObject:[NSNumber numberWithInt:(int)_enum ] forKey:_string ]

- (void) startup
{
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat, @"float");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat2, @"vec2");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat3, @"vec3");
    INSERTENUM(effectVariableTypes, NpEffectVariableFloat4, @"vec4");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt,  @"int");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt2, @"ivec2");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt3, @"ivec3");
    INSERTENUM(effectVariableTypes, NpEffectVariableInt4, @"ivec4");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix2x2, @"mat2");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix3x3, @"mat3");
    INSERTENUM(effectVariableTypes, NpEffectVariableFMatrix4x4, @"mat4");
}

#undef INSERTENUM

- (void) shutdown
{
    [ effectVariableTypes removeAllObjects ];
}

- (NpEffectVariableType) effectVariableTypeForString:(NSString *)string
{
    NpEffectVariableType result = NpEffectVariableUnknown;

    NSNumber * n = [ effectVariableTypes objectForKey:string ];
    if ( n != nil )
    {
        result = (NpEffectVariableType)[ n intValue ];
    }

    return result;
}

@end

