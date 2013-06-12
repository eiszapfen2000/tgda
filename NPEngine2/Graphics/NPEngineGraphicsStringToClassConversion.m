#import <Foundation/NSDictionary.h>
#import "NPEngineGraphicsStringToClassConversion.h"

static NSMutableDictionary * uniformTypeToClass = nil;

@implementation NPEngineGraphicsStringToClassConversion

#define INSERTCLASS(_dictionary, _vclass, _string) \
    [_dictionary setObject:NSClassFromString(_vclass) forKey:_string ]

+ (void) initialize
{
    uniformTypeToClass = [[ NSMutableDictionary alloc ] init ];

    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableFloat" , @"float");
    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableFloat2", @"vec2" );
    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableFloat3", @"vec3" );
    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableFloat4", @"vec4" );

    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableMatrix2x2", @"mat2" );
    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableMatrix3x3", @"mat3" );
    INSERTCLASS(uniformTypeToClass, @"NPEffectVariableMatrix4x4", @"mat4" );
}

#undef INSERTCLASS

- (id) initWithName:(NSString *)newName
{
    return [ super initWithName:newName ];
}

- (Class) classForUniformType:(NSString *)uniformType
{
    Class result = [ uniformTypeToClass objectForKey:uniformType ];

    if ( result == nil )
    {
        result = Nil;
    }

    return result;
}

@end

