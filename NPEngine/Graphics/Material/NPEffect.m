#import "NPEffect.h"
#import "NPEffectTechnique.h"
#import "NP.h"

@implementation NPEffect

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPEffect" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    defaultTechnique = nil;
    techniques = [[ NSMutableDictionary alloc ] init ];
    [ self clearDefaultSemantics ];

    return self;
}

- (void) dealloc
{
    if ( cgIsEffect(effect) == CG_TRUE )
    {
        cgDestroyEffect(effect);
    }

    TEST_RELEASE(defaultTechnique);
    [ techniques removeAllObjects ];
    [ techniques release ];

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self setName: [ file fileName ] ];
    [ self setFileName: [ file fileName ] ];

    // Hack because of buggy cg character encoding/line termination 
    NSData * data = [ file readEntireFile ];
    NSMutableData * mData = [ NSMutableData data ];
    [ mData appendData:data ];
    char c = 0;
    [ mData appendBytes:&c length:1 ];

    NSString * tmp = [ NSString stringWithUTF8String:[ mData bytes ]];
    effect = cgCreateEffect( [ (NPEffectManager *)parent cgContext ], [ tmp cStringUsingEncoding:NSASCIIStringEncoding ], NULL );

    if ( cgIsEffect(effect) == CG_FALSE )
    {
        NPLOG(@"%@: error while creating effect",fileName);
        return NO;
    }

    CGtechnique technique = cgGetFirstTechnique(effect);
    while ( technique != NULL )
    {
        NSString * techniqueName = [ NSString stringWithFormat:@"%s", cgGetTechniqueName(technique) ];

        if ( cgValidateTechnique(technique) == CG_FALSE )
        {
            NPLOG_WARNING(@"Technique \"%@\" did not validate", techniqueName );
        }
        else
        {
            NPEffectTechnique * effectTechnique = [[ NPEffectTechnique alloc ] initWithName:techniqueName
                                                                                parent:self
                                                                             technique:technique ];
            [ techniques setObject:effectTechnique forKey:techniqueName ];
            [ effectTechnique release ];

            NPLOG(@"Technique \"%@\" validated", techniqueName);
        }

        technique = cgGetNextTechnique(technique);
    }

    NSEnumerator * e = [ techniques objectEnumerator ];
    defaultTechnique = [[ e nextObject ] retain ];

    [ self bindDefaultSemantics ];

    ready = YES;

    return YES;
}

- (void) reset
{
    if ( cgIsEffect(effect) )
    {
        cgDestroyEffect(effect);
    }

    effect = NULL;
    defaultTechnique = nil;

    [ techniques removeAllObjects ];

    [ super reset ];
}

- (NpDefaultSemantics *) defaultSemantics
{
    return &defaultSemantics;
}

- (NPEffectTechnique *) defaultTechnique
{
    return defaultTechnique;
}

- (NPEffectTechnique *) techniqueWithName:(NSString *)techniqueName
{
    return [ techniques objectForKey:techniqueName ];
}

- (void) setDefaultTechnique:(NPEffectTechnique *)newDefaultTechnique
{
    ASSIGN(defaultTechnique, newDefaultTechnique);
}

- (void) clearDefaultSemantics
{
    defaultSemantics.modelMatrix = NULL;
    defaultSemantics.inverseModelMatrix = NULL;
    defaultSemantics.viewMatrix = NULL;
    defaultSemantics.inverseViewMatrix = NULL;
    defaultSemantics.projectionMatrix = NULL;
    defaultSemantics.inverseProjectionMatrix = NULL;
    defaultSemantics.modelViewMatrix = NULL;
    defaultSemantics.inverseModelViewMatrix = NULL;
    defaultSemantics.viewProjectionMatrix = NULL;
    defaultSemantics.inverseViewProjectionMatrix = NULL;
    defaultSemantics.modelViewProjectionMatrix = NULL;
    defaultSemantics.inverseModelViewProjectionMatrix = NULL;

    for ( Int i = 0; i < 8; i++ )
    {
        defaultSemantics.sampler1D[i] = NULL;
        defaultSemantics.sampler2D[i] = NULL;
        defaultSemantics.sampler3D[i] = NULL;
    }
}

- (CGparameter) bindDefaultSemantic:(NSString *)semanticName;
{
    CGparameter param = cgGetEffectParameterBySemantic(effect, [ semanticName cStringUsingEncoding:NSASCIIStringEncoding ]);

    if ( cgIsParameter(param) == CG_TRUE )
    {
        NPLOG(@"%@ with name %s found", semanticName, cgGetParameterName(param));
        //NPLOG(@"%s ",cgGetTypeString(cgGetParameterType(param)));
        return param;
    }

    return NULL;
}

- (void) bindDefaultSemantics
{
    defaultSemantics.modelMatrix                 = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_MODEL_MATRIX_SEMANTIC ];
    defaultSemantics.inverseModelMatrix          = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSE_MODEL_MATRIX_SEMANTIC ];
    defaultSemantics.viewMatrix                  = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_VIEW_MATRIX_SEMANTIC ];
    defaultSemantics.inverseViewMatrix           = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSE_VIEW_MATRIX_SEMANTIC ];
    defaultSemantics.projectionMatrix            = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_PROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.inverseProjectionMatrix     = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSE_PROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.modelViewMatrix             = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_MODELVIEW_MATRIX_SEMANTIC ];
    defaultSemantics.inverseModelViewMatrix      = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSE_MODELVIEW_MATRIX_SEMANTIC ];
    defaultSemantics.viewProjectionMatrix        = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_VIEWPROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.inverseViewProjectionMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSEVIEWPROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.modelViewProjectionMatrix   = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_MODELVIEWPROJECTION_MATRIX_SEMANTIC ];
    defaultSemantics.inverseModelViewProjectionMatrix = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_INVERSE_MODELVIEWPROJECTION_MATRIX_SEMANTIC ];

    //Int fontSamplerSlot = -1;
    for ( Int i = 0; i < 8; i++ )
    {
        defaultSemantics.sampler2D[i] = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(i)  ];
        defaultSemantics.sampler3D[i] = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_VOLUMEMAP_SEMANTIC(i) ];

        // Font uses a sampler2d, so we look for the first unused texel unit sampler
        /*if ( defaultSemantics.sampler2D[i] == NULL && fontSamplerSlot != -1 )
        {
            fontSamplerSlot = i;
        }*/
    }

    //defaultSemantics.sampler2D[fontSamplerSlot] = [ self bindDefaultSemantic:NP_GRAPHICS_MATERIAL_FONT_SEMANTIC ];
}

- (void) activate
{
    [[[ NP Graphics ] effectManager ] setCurrentEffect:self ];

    [ self uploadDefaultSemantics ];
}

- (void) uploadDefaultSemantics
{
    if ( defaultSemantics.modelMatrix != NULL )
    {
        FMatrix4 * modelMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] modelMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.modelMatrix andValue:modelMatrix ];
    }

    if ( defaultSemantics.inverseModelMatrix != NULL )
    {
        FMatrix4 * inverseModelMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseModelMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseModelMatrix andValue:inverseModelMatrix ];
    }

    if ( defaultSemantics.viewMatrix != NULL )
    {
        FMatrix4 * viewMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] viewMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.viewMatrix andValue:viewMatrix ];
    }

    if ( defaultSemantics.inverseViewMatrix != NULL )
    {
        FMatrix4 * inverseViewMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseViewMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseViewMatrix andValue:inverseViewMatrix ];
    }

    if ( defaultSemantics.projectionMatrix != NULL )
    {
        FMatrix4 * projectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] projectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.projectionMatrix andValue:projectionMatrix ];
    }

    if ( defaultSemantics.inverseProjectionMatrix != NULL )
    {
        FMatrix4 * inverseProjectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseProjectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseProjectionMatrix andValue:inverseProjectionMatrix ];
    }

    if ( defaultSemantics.modelViewMatrix != NULL )
    {
        FMatrix4 * modelViewMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] modelViewMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.modelViewMatrix andValue:modelViewMatrix ];
    }

    if ( defaultSemantics.inverseModelViewMatrix != NULL )
    {
        FMatrix4 * inverseModelViewMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseModelViewMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseModelViewMatrix andValue:inverseModelViewMatrix ];
    }

    if ( defaultSemantics.viewProjectionMatrix != NULL )
    {
        FMatrix4 * viewProjectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] viewProjectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.viewProjectionMatrix andValue:viewProjectionMatrix ];
    }

    if ( defaultSemantics.inverseViewProjectionMatrix != NULL )
    {
        FMatrix4 * inverseViewProjectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseViewProjectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseViewProjectionMatrix andValue:inverseViewProjectionMatrix ];
    }

    if ( defaultSemantics.modelViewProjectionMatrix != NULL )
    {
        FMatrix4 * modelViewProjectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] modelViewProjectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.modelViewProjectionMatrix andValue:modelViewProjectionMatrix ];
    }

    if ( defaultSemantics.inverseModelViewProjectionMatrix != NULL )
    {
        FMatrix4 * inverseModelViewProjectionMatrix = [[[[ NP Core ] transformationStateManager ] currentTransformationState ] inverseModelViewProjectionMatrix ];
        [ self uploadFMatrix4Parameter:defaultSemantics.inverseModelViewProjectionMatrix andValue:inverseModelViewProjectionMatrix ];
    }

    NPTextureBindingState * textureBindingState = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];
    for ( Int i = 0; i < 8; i++ )
    {
        if ( defaultSemantics.sampler2D[i] != NULL )
        {
            NPTexture * texture = [ textureBindingState textureForKey:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(i) ];

            [ self uploadSampler2DWithParameter:defaultSemantics.sampler2D[i] andID:[texture textureID] ];
        }

        if ( defaultSemantics.sampler3D[i] != NULL )
        {
            NPTexture3D * texture3D = [ textureBindingState textureForKey:NP_GRAPHICS_MATERIAL_VOLUMEMAP_SEMANTIC(i) ];

            [ self uploadSampler3DWithParameter:defaultSemantics.sampler3D[i] andID:[texture3D textureID] ];
        }
    }
}

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float)f
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    [ self upLoadFloatParameter:parameter andValue:f ];
}

- (void) upLoadFloatParameter:(CGparameter)parameter andValue:(Float)f
{
    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        if ( cgGetParameterType(parameter) == CG_FLOAT )
        {
            cgSetParameter1f(parameter,f);
        }
    }
}

- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32)i
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    [ self upLoadIntParameter:parameter andValue:i ];
}

- (void) upLoadIntParameter:(CGparameter)parameter andValue:(Int32)i
{
    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        if ( cgGetParameterType(parameter) == CG_INT )
        {
            cgSetParameter1i(parameter,i);
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
        if ( cgGetParameterType(parameter) == CG_FLOAT2 )
        {
            cgSetParameter2f(parameter,V_X(*vector),V_Y(*vector));
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
        if ( cgGetParameterType(parameter) == CG_FLOAT3 )
        {
            cgSetParameter3f(parameter,V_X(*vector),V_Y(*vector),V_Z(*vector));
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
        if ( cgGetParameterType(parameter) == CG_FLOAT4 )
        {
            cgSetParameter4f(parameter,V_X(*vector),V_Y(*vector),V_Z(*vector),V_W(*vector));
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
        if ( cgGetParameterType(parameter) == CG_FLOAT2x2 )
        {
            cgSetMatrixParameterfc(parameter,(const float *)M_ELEMENTS(*matrix));
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
        if ( cgGetParameterType(parameter) == CG_FLOAT3x3 )
        {
            cgSetMatrixParameterfc(parameter,(const float *)M_ELEMENTS(*matrix));
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
        if ( cgGetParameterType(parameter) == CG_FLOAT4x4 )
        {
            cgSetMatrixParameterfc(parameter,(const float *)M_ELEMENTS(*matrix));
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
            //cgGLSetTextureParameter(parameter,textureID);
            cgGLSetupSampler(parameter, textureID);
        }
    }    
}

- (void) uploadSampler3DWithParameterName:(NSString *)parameterName andID:(GLuint)textureID
{
    CGparameter parameter = cgGetNamedEffectParameter(effect,[parameterName cString]);

    [ self uploadSampler3DWithParameter:parameter andID:textureID ];
}

- (void) uploadSampler3DWithParameter:(CGparameter)parameter andID:(GLuint)textureID
{
    if ( cgIsParameter(parameter) == CG_TRUE )
    {
        if ( cgGetParameterType(parameter) == CG_SAMPLER3D )
        {
            //cgGLSetTextureParameter(parameter,textureID);
            cgGLSetupSampler(parameter, textureID);
        }
    }    
}

@end
