#import "NPEffect.h"
#import "NPEffectManager.h"

#import "Core/NPEngineCore.h"

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
        NPLOG(@"Parent must be of Class NPEffectManager");
    }

    [ self clearDefaultSemantics ];

    return self;
}

- (void) dealloc
{
    cgDestroyEffect(effect);

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setName: [ file fileName ] ];
    [ self setFileName: [ file fileName ] ];

    effect = cgCreateEffect( [ (NPEffectManager *)parent cgContext ], [ [ file readEntireFile ] bytes ], NULL );

    if ( cgIsEffect(effect) == CG_FALSE )
    {
        NPLOG(([NSString stringWithFormat:@"%@: error while creating effect",fileName]));
        return NO;
    }

    CGtechnique technique = cgGetFirstTechnique(effect);
    defaultTechnique = technique;

    while ( technique != NULL )
    {
        if ( cgValidateTechnique(technique) == CG_FALSE )
        {
            NPLOG_WARNING(([NSString stringWithFormat:@"Technique %s did not validate",cgGetTechniqueName(technique)]));
        }
        else
        {
            NPLOG(([NSString stringWithFormat:@"Technique \"%s\" validated",cgGetTechniqueName(technique)]));
        }

        technique = cgGetNextTechnique(technique);
    }

    [ self bindDefaultSemantics ];

    ready = YES;

    return YES;
}

- (void) reset
{
    cgDestroyEffect(effect);
    effect = NULL;
    defaultTechnique = NULL;

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (CGeffect) effect
{
    return effect;
}

- (CGtechnique) defaultTechnique
{
    return defaultTechnique;
}

- (void) setDefaultTechnique:(CGtechnique)newDefaultTechnique
{
    defaultTechnique = newDefaultTechnique;
}

- (NpDefaultSemantics *) defaultSemantics
{
    return &defaultSemantics;
}

- (void) clearDefaultSemantics
{
    defaultSemantics.modelMatrix = NULL;
    defaultSemantics.viewMatrix = NULL;
    defaultSemantics.projectionMatrix = NULL;
    defaultSemantics.modelViewProjectionMatrix = NULL;

    for ( Int i = 0; i < 8; i++ )
    {
        defaultSemantics.sampler[i] = NULL;
    }
}

- (CGparameter) bindDefaultSemantic:(NSString *)semanticName;
{
    CGparameter param = cgGetEffectParameterBySemantic(effect, [ semanticName cStringUsingEncoding:NSASCIIStringEncoding ]);

    if ( cgIsParameter(param) == CG_TRUE )
    {
        NPLOG(([NSString stringWithFormat:@"%@ with name %s found",semanticName,cgGetParameterName(param)]));
        NPLOG(([NSString stringWithFormat:@"%s ",cgGetTypeString(cgGetParameterType(param))]));
        return param;
    }

    return NULL;
}

- (void) bindDefaultSemantics
{
    defaultSemantics.modelMatrix = [ self bindDefaultSemantic:@"NPMODEL" ];
    defaultSemantics.viewMatrix = [ self bindDefaultSemantic:@"NPVIEW" ];;
    defaultSemantics.projectionMatrix = [ self bindDefaultSemantic:@"NPPROJECTION" ];;
    defaultSemantics.modelViewProjectionMatrix = [ self bindDefaultSemantic:@"NPMODELVIEWPROJECTION" ];

    NSString * samplerSemantic = @"COLORMAP";

    for ( Int i = 0; i < 8; i++ )
    {
        NSString * ithSampler = [ samplerSemantic stringByAppendingFormat:@"%d",i ];
        defaultSemantics.sampler[i] = [ self bindDefaultSemantic:ithSampler ];
    }

    /*for ( Int i = 0; i < 8; i++ )
    {
        if ( defaultSemantics.sampler[i] == NULL )
        {
            NPLOG(@"NULL");
        }
        else
        {
            NPLOG(([NSString stringWithFormat:@"%s ",cgGetParameterName(defaultSemantics.sampler[i])]));
        }
        //NPLOG(([NSString stringWithFormat:@"%s",cgGetParameterName(defaultSemantics.sampler[i])]));
    }*/
}

- (void) activate
{

}

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_SCALAR )
        if ( cgGetParameterType(parameter) == CG_FLOAT )
        {
            cgSetParameter1f(parameter,*f);
        }
    }
}

- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32 *)i
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_SCALAR )
        if ( cgGetParameterType(parameter) == CG_INT )
        {
            cgSetParameter1i(parameter,*i);
        }
    }
}

- (void) uploadFVector2ParameterWithName:(NSString *)parameterName andValue:(FVector2 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        if ( cgGetParameterType(parameter) == CG_FLOAT2 )
        {
            cgSetParameter2f(parameter,FV_X(*vector),FV_Y(*vector));
        }
    }
}

- (void) uploadFVector3ParameterWithName:(NSString *)parameterName andValue:(FVector3 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        if ( cgGetParameterType(parameter) == CG_FLOAT3 )
        {
            cgSetParameter3f(parameter,FV_X(*vector),FV_Y(*vector),FV_Z(*vector));
        }
    }
}

- (void) uploadFVector4ParameterWithName:(NSString *)parameterName andValue:(FVector4 *)vector
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_VECTOR )
        if ( cgGetParameterType(parameter) == CG_FLOAT4 )
        {
            cgSetParameter4f(parameter,FV_X(*vector),FV_Y(*vector),FV_Z(*vector),FV_W(*vector));
        }
    }
}

- (void) uploadFMatrix2ParameterWithName:(NSString *)parameterName andValue:(FMatrix2 *)matrix
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_MATRIX )
        if ( cgGetParameterType(parameter) == CG_FLOAT2x2 )
        {
            //if ( cgGetParameterRows(parameter) == 2 && cgGetParameterColumns(parameter) == 2 )
            //{
                cgSetMatrixParameterfc(parameter,(const float *)FM_ELEMENTS(*matrix));
            //}
        }
    }
}

- (void) uploadFMatrix3ParameterWithName:(NSString *)parameterName andValue:(FMatrix3 *)matrix
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_MATRIX )
        if ( cgGetParameterType(parameter) == CG_FLOAT3x3 )
        {
            //if ( cgGetParameterRows(parameter) == 3 && cgGetParameterColumns(parameter) == 3 )
            //{
                cgSetMatrixParameterfc(parameter,(const float *)FM_ELEMENTS(*matrix));
            //}
        }
    }
}

- (void) uploadFMatrix4ParameterWithName:(NSString *)parameterName andValue:(FMatrix4 *)matrix
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        //if ( cgGetParameterClass(parameter) == CG_PARAMETERCLASS_MATRIX )
        if ( cgGetParameterType(parameter) == CG_FLOAT4x4 )
        {
            //if ( cgGetParameterRows(parameter) == 4 && cgGetParameterColumns(parameter) == 4 )
            //{
                cgSetMatrixParameterfc(parameter,(const float *)FM_ELEMENTS(*matrix));
            //}
        }
    }
}

- (void) uploadSampler2DWithParameter:(CGparameter)parameter andID:(GLuint)textureID
{
    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        if ( cgGetParameterType(parameter) == CG_SAMPLER2D )
        {
            cgGLSetupSampler(parameter, textureID);
        }
    }    
}

@end
