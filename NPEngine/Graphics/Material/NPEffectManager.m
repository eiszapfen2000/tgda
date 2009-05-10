#import "NPEffectManager.h"
#import "NP.h"

void np_cg_error_callback()
{
	CGerror error;
	const char * string = cgGetLastErrorString(&error);

	if (error != CG_NO_ERROR) 
	{
		if (error == CG_COMPILER_ERROR) 
		{
			const char * cgListing = cgGetLastListing([[[ NP Graphics ] effectManager] cgContext]);

		    NPLOG_ERROR(@"CG ERROR: %s \n Cg Compiler Output: %s", string, cgListing);
		} 
		else 
		{
		    NPLOG_ERROR(@"CG ERROR: %s \n %s", string);
		}

		error = cgGetError();
	}

	error = cgGetError();
}

@implementation NPEffectManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPEffectManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    cgDebugMode = NP_NONE;
    shaderParameterUpdatePolicy = NP_NONE;

    effects = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) setup
{
    NPLOG(@"NPEffectManager setup...");

    NPLOG(([NSString stringWithFormat:@"Using CG %s",cgGetString(CG_VERSION)]));

    cgSetErrorCallback(np_cg_error_callback);

    NPLOG(@"Creating CG Context...");
    cgContext = cgCreateContext();
    NPLOG(@"...done");

    NPLOG(@"Register GL States with CG...");
    cgGLRegisterStates(cgContext);
    NPLOG(@"...done");

    NPLOG(@"Activate CG Texture Parameter Management...");
    cgGLSetManageTextureParameters(cgContext, CG_TRUE);
    NPLOG(@"...done");

    [ self setCgDebugMode:NP_CG_DEBUG_MODE_ACTIVE ];
    [ self setShaderParameterPolicy:NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE ];

    NPLOG(@"Effect Manager ready");
}

- (void) dealloc
{
	TEST_RELEASE(currentEffect);
    [ effects removeAllObjects ];
    [ effects release ];

    cgDestroyContext(cgContext);

    [ super dealloc ];
}

- (CGcontext)cgContext
{
    return cgContext;
}

- (NpState) cgDebugMode
{
    return cgDebugMode;
}

- (NpState)shaderParameterUpdatePolicy
{
    return shaderParameterUpdatePolicy;
}

- (NPEffect *) currentEffect;
{
    return currentEffect;
}

- (void) setCgDebugMode:(NpState)newMode
{
    if ( cgDebugMode != newMode )
    {
        cgDebugMode = newMode;

        switch ( newMode )
        {
            case NP_CG_DEBUG_MODE_ACTIVE  :{ cgGLSetDebugMode( CG_TRUE );  break; }
            case NP_CG_DEBUG_MODE_INACTIVE:{ cgGLSetDebugMode( CG_FALSE ); break; }
            case NP_NONE:{ break; }
        }
    }
}

- (void) setShaderParameterPolicy:(NpState)newShaderParameterUpdatePolicy
{
    if ( shaderParameterUpdatePolicy != newShaderParameterUpdatePolicy )
    {
        shaderParameterUpdatePolicy = newShaderParameterUpdatePolicy;

        switch ( newShaderParameterUpdatePolicy )
        {
            case NP_CG_IMMEDIATE_SHADER_PARAMETER_UPDATE:
            {
                cgSetParameterSettingMode(cgContext,CG_IMMEDIATE_PARAMETER_SETTING);
                break;
            }

            case NP_CG_DEFERRED_SHADER_PARAMETER_UPDATE:
            {
                cgSetParameterSettingMode(cgContext,CG_DEFERRED_PARAMETER_SETTING);
                break;
            }

            case NP_NONE:
            {
                break;
            }
        }
    }
}

- (void) setCurrentEffect:(NPEffect *)newCurrentEffect
{
    ASSIGN(currentEffect,newCurrentEffect);
}

- (id) loadEffectFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadEffectFromAbsolutePath:absolutePath ];
}

- (id) loadEffectFromAbsolutePath:(NSString *)path
{
    NPLOG(@"%@: loading %@", name, path);

    if ( [ path isEqual:@"" ] == NO )
    {
        NPEffect * effect = [ effects objectForKey:path ];

        if ( effect == nil )
        {
            NPFile * file = [[ NPFile alloc ] initWithName:path parent:self fileName:path ];
            effect = [ self loadEffectUsingFileHandle:file ];
            [ file release ];
        }

        return effect;
    }

    return nil;
}

- (id) loadEffectUsingFileHandle:(NPFile *)file
{
    NPEffect * effect = [[ NPEffect alloc ] initWithName:@"" parent:self ];

    if ( [ effect loadFromFile:file ] == YES )
    {
        [ effects setObject:effect forKey:[file fileName] ];
        [ effect release ];

        return effect;
    }
    else
    {
        [ effect release ];

        return nil;
    }
}

@end
