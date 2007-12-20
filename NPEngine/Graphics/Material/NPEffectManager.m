#import "NPEffectManager.h"

@implementation NPEffectManager

- (id) init
{
    return [ self initWithParent:nil ];
}
- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPEffectManager" parent:newParent ];
}
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    cgContext = cgCreateContext();

    cgDebugMode = NO;
    shaderParameterUpdatePolicy = NP_NONE;

    effects = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ effects release ];

    [ super dealloc ];
}

- (CGcontext)cgContext
{
    return cgContext;
}

- (BOOL) cgDebugMode
{
    return cgDebugMode;
}

- (void) setCgDebugMode:(BOOL)newMode
{
    if ( cgDebugMode != newMode )
    {
        cgDebugMode = newMode;

        switch ( newMode )
        {
            case YES:
            {
                cgGLSetDebugMode( CG_TRUE );
            }

            case NO:
            {
                cgGLSetDebugMode( CG_FALSE );
            }
        }
    }
}

- (NpCgShaderParameterUpdatePolicy)shaderParameterUpdatePolicy
{
    return shaderParameterUpdatePolicy;
}

- (void) setShaderParamterPolicy:(NpCgShaderParameterUpdatePolicy)newShaderParameterUpdatePolicy
{
    if ( shaderParameterUpdatePolicy != newShaderParameterUpdatePolicy )
    {
        shaderParameterUpdatePolicy = newShaderParameterUpdatePolicy;

        switch ( newShaderParameterUpdatePolicy )
        {
            case NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE:
            {
                cgSetParameterSettingMode(cgContext,CG_IMMEDIATE_PARAMETER_SETTING);
            }

            case NP_CG_DEFERRED_SHADER_PARAMETER_UPDATE:
            {
                cgSetParameterSettingMode(cgContext,CG_DEFERRED_PARAMETER_SETTING);
            }

            case NP_NONE:
            {
                return;
            }
        }
    }
}

@end
