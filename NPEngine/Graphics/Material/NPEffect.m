#import "NPTexture.h"
#import "NPTextureBindingState.h"
#import "NPTextureBindingStateManager.h"
#import "NPEffect.h"
#import "NPEffectManager.h"
#import "Core/World/NPTransformationState.h"
#import "Core/World/NPTransformationStateManager.h"

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
    defaultSemantics.modelMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_MODEL_MATRIX_SEMANTIC ];
    defaultSemantics.viewMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_VIEW_MATRIX_SEMANTIC ];
    defaultSemantics.projectionMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_PROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.modelViewProjectionMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_MODELVIEWPROJECTION_MATRIX_SEMANTIC ];

    for ( Int i = 0; i < 8; i++ )
    {
        defaultSemantics.sampler[i] = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(i) ];
    }
}

- (void) activate
{
    [[[NPEngineCore instance ] effectManager ] setCurrentActiveEffect:self ];

    [ self uploadDefaultSemantics ];
}

- (void) uploadDefaultSemantics
{
    if ( defaultSemantics.modelMatrix != NULL )
    {
        FMatrix4 * modelMatrix = [[[[ NPEngineCore instance ] transformationStateManager ] currentActiveTransformationState ] modelMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.modelMatrix andValue:modelMatrix ];
    }

    if ( defaultSemantics.viewMatrix != NULL )
    {
        FMatrix4 * viewMatrix = [[[[ NPEngineCore instance ] transformationStateManager ] currentActiveTransformationState ] viewMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.viewMatrix andValue:viewMatrix ];
    }

    if ( defaultSemantics.projectionMatrix != NULL )
    {
        FMatrix4 * projectionMatrix = [[[[ NPEngineCore instance ] transformationStateManager ] currentActiveTransformationState ] projectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.projectionMatrix andValue:projectionMatrix ];
    }

    if ( defaultSemantics.modelViewProjectionMatrix != NULL )
    {
    }

    NPTextureBindingState * textureBindingState = [[[NPEngineCore instance ] textureBindingStateManager ] currentTextureBindingState ];

    for ( Int i = 0; i < 8; i++ )
    {
        if ( defaultSemantics.sampler[i] != NULL )
        {
            NPTexture * texture = [ textureBindingState textureForKey:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(i) ];

            [ self uploadSampler2DWithParameter:defaultSemantics.sampler[i] andID:[texture textureID] ];
        }
    }
}

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    [ self upLoadFloatParameter:parameter andValue:f ];
}

- (void) upLoadFloatParameter:(CGparameter)parameter andValue:(Float *)f
{
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

    [ self upLoadIntParameter:parameter andValue:i ];
}

- (void) upLoadIntParameter:(CGparameter)parameter andValue:(Int32 *)i
{
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

    [ self uploadFVector2Parameter:parameter andValue:vector ];
}

- (void) uploadFVector2Parameter:(CGparameter)parameter andValue:(FVector2 *)vector
{
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

    [ self uploadFVector3Parameter:parameter andValue:vector ];
}

- (void) uploadFVector3Parameter:(CGparameter)parameter andValue:(FVector3 *)vector
{
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

    [ self uploadFVector4Parameter:parameter andValue:vector ];
}

- (void) uploadFVector4Parameter:(CGparameter)parameter andValue:(FVector4 *)vector
{
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

    [ self uploadFMatrix2Parameter:parameter andValue:matrix ];
}

- (void) uploadFMatrix2Parameter:(CGparameter)parameter andValue:(FMatrix2 *)matrix
{
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

    [ self uploadFMatrix3Parameter:parameter andValue:matrix ];
}

- (void) uploadFMatrix3Parameter:(CGparameter)parameter andValue:(FMatrix3 *)matrix
{
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

    [ self uploadFMatrix4Parameter:parameter andValue:matrix ];
}

- (void) uploadFMatrix4Parameter:(CGparameter)parameter andValue:(FMatrix4 *)matrix
{
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

- (void) uploadSampler2DWithParameterName:(NSString *)parameterName andID:(GLuint)textureID
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    [ self uploadSampler2DWithParameter:parameter andID:textureID ];
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
