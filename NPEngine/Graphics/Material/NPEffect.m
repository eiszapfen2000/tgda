#import "NPEffect.h"
#import "NPEffectManager.h"

@implementation NPEffect

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPEffect" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    if ( [ newParent isMemberOfClass:[ NPEffectManager class ] ] == NO )
    {
        NSLog(@"das wird schief gehen");
    }

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setFileName: [ file fileName ] ];

    effect = cgCreateEffect( [ (NPEffectManager *)parent cgContext ], [ [ file readEntireFile ] bytes ], NULL );

    if ( effect == NULL )
    {
        return NO;
    }

    return YES;
}

- (void) reset
{
    cgDestroyEffect(effect);

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}


- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( parameter != NULL )
    {
        if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_SCALAR )
        {
            cgSetParameter1f(parameter,*f);
        }
    }
}

- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32 *)i
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( parameter != NULL )
    {
        if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_SCALAR )
        {
            cgSetParameter1i(parameter,*i);
        }
    }
}

- (void) uploadFVector2ParameterWithName:(NSString *)parameterName andValue:(FVector2 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( parameter != NULL )
    {
        if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        {
            cgSetParameter2f(parameter,FV_X(*vector),FV_Y(*vector));
        }
    }
}

- (void) uploadFVector3ParameterWithName:(NSString *)parameterName andValue:(FVector3 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( parameter != NULL )
    {
        if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        {
            cgSetParameter3f(parameter,FV_X(*vector),FV_Y(*vector),FV_Z(*vector));
        }
    }
}

- (void) uploadFVector4ParameterWithName:(NSString *)parameterName andValue:(FVector4 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( parameter != NULL )
    {
        if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        {
            cgSetParameter4f(parameter,FV_X(*vector),FV_Y(*vector),FV_Z(*vector),FV_W(*vector));
        }
    }
}

- (void) uploadFMatrix2ParameterWithName:(NSString *)parameterName andValue:(FMatrix2 *)matrix
{
}

- (void) uploadFMatrix3ParameterWithName:(NSString *)parameterName andValue:(FMatrix3 *)matrix
{
}

- (void) uploadFMatrix4ParameterWithName:(NSString *)parameterName andValue:(FMatrix4 *)matrix
{
}

@end
