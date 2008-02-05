#import "NPEffect.h"
#import "NPEffectManager.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPPathManager.h"
#import "Core/NPEngineCore.h"

@implementation NPEffectManager

- (void) checkForCgErrors
{
    char buffer[4096];
    CGerror error;
    const char *string = cgGetLastErrorString(&error);
  
    if (error != CG_NO_ERROR)
    {
        if (error == CG_COMPILER_ERROR)
        {
            sprintf(buffer,
              "Error: %s\n\n"
              "Cg compiler output...\n",
              string);

            printf("%s", buffer);
            printf("%s\n", cgGetLastListing([ (NPEffectManager *)parent cgContext ]));
        }
        else
        {
            sprintf(buffer,
              "Error: %s",
              string);

            printf("%s\n", buffer);
        }
    }
}

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
    [ self checkForCgErrors ];

    cgGLRegisterStates(cgContext);
    [ self checkForCgErrors ];

    cgGLSetManageTextureParameters(cgContext, CG_TRUE);
    [ self checkForCgErrors ];

    cgDebugMode = NP_NONE;
    shaderParameterUpdatePolicy = NP_NONE;

    effects = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ effects release ];

    cgDestroyContext(cgContext);

    [ super dealloc ];
}

- (CGcontext)cgContext
{
    return cgContext;
}

- (NPState) cgDebugMode
{
    return cgDebugMode;
}

- (void) setCgDebugMode:(NPState)newMode
{
    if ( cgDebugMode != newMode )
    {
        cgDebugMode = newMode;

        switch ( newMode )
        {
            case NP_CG_DEBUG_MODE_ACTIVE:
            {
                cgGLSetDebugMode( CG_TRUE );
                break;
            }

            case NP_CG_DEBUG_MODE_INACTIVE:
            {
                cgGLSetDebugMode( CG_FALSE );
                break;
            }

            case NP_NONE:
            {
                break;
            }
        }
    }
}

- (NPState)shaderParameterUpdatePolicy
{
    return shaderParameterUpdatePolicy;
}

- (void) setShaderParamterPolicy:(NPState)newShaderParameterUpdatePolicy
{
    if ( shaderParameterUpdatePolicy != newShaderParameterUpdatePolicy )
    {
        shaderParameterUpdatePolicy = newShaderParameterUpdatePolicy;

        switch ( newShaderParameterUpdatePolicy )
        {
            case NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE:
            {
                //cgSetParameterSettingMode(cgContext,CG_IMMEDIATE_PARAMETER_SETTING);
                break;
            }

            case NP_CG_DEFERRED_SHADER_PARAMETER_UPDATE:
            {
                //cgSetParameterSettingMode(cgContext,CG_DEFERRED_PARAMETER_SETTING);
                break;
            }

            case NP_NONE:
            {
                break;
            }
        }
    }
}

- (id) loadEffectFromPath:(NSString *)path
{
    NSString * absolutePath = [ [ [ NPEngineCore instance ] pathManager ] getAbsoluteFilePath:path ];
    NSLog(absolutePath);

    if ( [ absolutePath isEqual:path ] == NO )
    {
        NPEffect * effect = [ effects objectForKey:absolutePath ];

        if ( effect == nil )
        {
            NPFile * file = [ [ NPFile alloc ] initWithName:path parent:self fileName:absolutePath ];
            effect = [ [ NPEffect alloc ] initWithName:@"" parent:self ];

            if ( [ effect loadFromFile:file ] == YES )
            {
                [ effects setObject:effect forKey:absolutePath ];
                [ effect release ];
                [ file release ];

                return effect;
            }
            else
            {
                [ effect release ];
                [ file release ];

                return nil;
            }
        }
        else
        {
            return effect;
        }
    }

    return nil;
}

@end
