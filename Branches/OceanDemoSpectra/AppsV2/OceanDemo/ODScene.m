#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Geometry/NPFullscreenQuad.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTexture2DArray.h"
#import "Graphics/Texture/NPTexture3D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/Effect/NPEffectVariableInt.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/RenderTarget/NPRenderBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/State/NPBlendingState.h"
#import "Graphics/State/NPCullingState.h"
#import "Graphics/State/NPDepthTestState.h"
#import "Graphics/State/NPPolygonFillState.h"
#import "Graphics/State/NPStencilTestState.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/NPViewport.h"
#import "NP.h"
#import "Entities/ODBasePlane.h"
#import "Entities/ODPEntity.h"
#import "Entities/ODCamera.h"
#import "Entities/ODFrustum.h"
#import "Entities/ODIWave.h"
#import "Entities/ODProjector.h"
#import "Entities/ODProjectedGrid.h"
#import "Entities/ODPreethamSkylight.h"
#import "Entities/ODOceanEntity.h"
#import "Entities/ODEntity.h"
#import "Entities/ODWorldCoordinateAxes.h"
#import "ODScene.h"

static const NSUInteger defaultVarianceLUTResolutionIndex = 0;
static const uint32_t varianceLUTResolutions[4] = {4, 8, 12, 16};


@interface ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
                                     ;

- (BOOL) generateRenderTargets:(NSError **)error;
- (BOOL) generateVarianceLUTRenderTarget:(uint32_t)resolution
                                   error:(NSError **)error
                                        ;

- (void) updateSlopeVarianceLUT:(uint32_t)resolution;
- (void) renderProjectedGrid;

@end

@implementation ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
{
    NSAssert(fileName != nil, @"");

    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        NPLOG_ERROR([ NSError fileNotFoundError:fileName ]);
        return nil;
    }

    NSDictionary * entityConfig
        = [ NSDictionary dictionaryWithContentsOfFile:absoluteFileName ];

    NSString * typeClassString  = [ entityConfig objectForKey:@"Type" ];
    NSString * entityNameString = [ entityConfig objectForKey:@"Name" ];

    NSAssert(typeClassString != nil && entityNameString != nil, @"");

    id <ODPEntity> entity
        = (id <ODPEntity>)[ entities objectWithName:entityNameString ];

    if ( entity != nil )
    {
        return entity;
    }

    NPLOG(@"");
    NPLOG(@"Loading %@", absoluteFileName);

    Class entityClass = NSClassFromString(typeClassString);
    if ( entityClass == Nil )
    {
        NPLOG(@"Error: Unknown entity type \"%@\", skipping",
              typeClassString);

        return nil;
    }

    entity = [[ entityClass alloc ] initWithName:@"" ];

    BOOL result
        = [ entity loadFromDictionary:entityConfig 
                                error:NULL ];

    if ( result == YES )
    {
        AUTORELEASE(entity);
    }
    else
    {
        NPLOG(@"Error: failed to load %@", absoluteFileName);
        DESTROY(entity);
    }

    return entity;
}

- (BOOL) generateRenderTargets:(NSError **)error
{
    BOOL result
        = [ linearsRGBTarget generate:NpRenderTargetColor
                                width:currentResolution.x
                               height:currentResolution.y
                          pixelFormat:NpTexturePixelFormatRGBA
                           dataFormat:NpTextureDataFormatFloat16
                        mipmapStorage:NO
                                error:error ];

    result
        = result && [ logLuminanceTarget generate:NpRenderTargetColor
                                            width:currentResolution.x
                                           height:currentResolution.y
                                      pixelFormat:NpTexturePixelFormatR
                                       dataFormat:NpTextureDataFormatFloat16
                                    mipmapStorage:YES
                                            error:error ];

    result
        = result && [ depthBuffer generate:NpRenderTargetDepthStencil
                                     width:currentResolution.x
                                    height:currentResolution.y
                               pixelFormat:NpTexturePixelFormatDepthStencil
                                dataFormat:NpTextureDataFormatUInt32N
                                     error:error ];

    return result;
}

- (BOOL) generateVarianceLUTRenderTarget:(uint32_t)resolution
                                   error:(NSError **)error
{
    return
        [ varianceLUT generate3D:NpRenderTargetColor
                           width:resolution
                          height:resolution
                           depth:resolution
                     pixelFormat:NpTexturePixelFormatRG
                      dataFormat:NpTextureDataFormatFloat16
                   mipmapStorage:NO
                           error:error ];
}

- (void) updateSlopeVarianceLUT:(uint32_t)resolution
{
    [ varianceTextureResolution setFValue:(float)resolution ];
    [ deltaVariance setFValue:[ ocean baseSpectrumDeltaVariance ]];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean baseSpectrum ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean sizes ]        texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    FRectangle vertices;
    FRectangle texcoords;

    frectangle_rssss_init_with_min_max(&vertices, -1.0f, -1.0f, 1.0f, 1.0f);
    frectangle_rssss_init_with_min_max(&texcoords, 0.0f, 0.0f, resolution, resolution);

    [ varianceRTC bindFBO ];
    [ varianceRTC activateViewport ];

    for ( uint32_t c = 0; c < resolution; c++ )
    {
        [ varianceLUT attachLevel:0
                            layer:c
        renderTargetConfiguration:varianceRTC
                 colorBufferIndex:0
                          bindFBO:NO ];

        if ( c == 0 )
        {
            [ varianceRTC activateDrawBuffers ];
        }

        [ layer setFValue:(float)c ];
        [ variance activate ];
        [ NPIMRendering renderFRectangle:vertices
                               texCoords:texcoords
                           primitiveType:NpPrimitiveQuads ];
    }

    [ varianceRTC deactivate ];
}

- (void) renderProjectedGrid
{
}

@end

static const OdCameraMovementEvents testCameraMovementEvents
    = {.rotate  = NpKeyboardG, .strafe   = NpInputEventUnknown,
       .forward = NpKeyboardW, .backward = NpKeyboardS };

static const OdProjectorRotationEvents testProjectorRotationEvents
    = {.pitchMinus = NpInputEventUnknown, .pitchPlus = NpInputEventUnknown,
       .yawMinus   = NpInputEventUnknown, .yawPlus   = NpInputEventUnknown };

@implementation ODScene

+ (void) shutdown
{
    [ ODEntity shutdown ];
}

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    camera    = [[ ODCamera       alloc ] init ];
    entities  = [[ NSMutableArray alloc ] init ];

    testCamera = [[ ODCamera alloc ] initWithName:@"TestCamera"  movementEvents:testCameraMovementEvents ];
    [ testCamera setFarPlane:50.0 ];

    cameraFrustum = [[ ODFrustum alloc ] initWithName:@"CFrustum" ];
    testCameraFrustum = [[ ODFrustum alloc ] initWithName:@"TCFrustum" ];
    testProjectorFrustum = [[ ODFrustum alloc ] initWithName:@"TPFrustum" ];

    iwave = [[ ODIWave alloc ] init ];
    ocean = [[ ODOceanEntity alloc ] initWithName:@"Ocean" ];
    skylight = [[ ODPreethamSkylight alloc ] init ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"ProjGrid" ];
    axes = [[ ODWorldCoordinateAxes alloc ] init ];

    // camera animation
    fquat_set_identity(&startOrientation);
    fquat_set_identity(&endOrientation);
    fv3_v_init_with_zeros(&startPosition);
    fv3_v_init_with_zeros(&endPosition);
    animationTime = 0.0f;
    connecting = NO;
    disconnecting = NO;

    jacobianEpsilon = 0.2;

    // tonemapping parameters
    deltaTime = 0.0;
    lastAdaptedLuminance = 0.0;
    referenceWhite = 4.0;
    key = 0.72;
    adaptationTimeScale = 10.0;
    lastFrameLuminance = currentFrameLuminance = 1.0;

    // render target resolution
    lastFrameResolution.x = lastFrameResolution.y = INT_MAX;
    currentResolution.x = currentResolution.y = 0;

    //
    whitecapsRtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"Whitecaps RTC" ];   
    whitecapsTarget = [[ NPRenderTexture alloc ] init ];

    // g buffer
    rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"General RTC" ];
    linearsRGBTarget   = [[ NPRenderTexture alloc ] init ];
    logLuminanceTarget = [[ NPRenderTexture alloc ] init ];
    depthBuffer        = [[ NPRenderBuffer  alloc ] init ];

    deferredEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"deferred.effect" ];

    projectedGridEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"projected_grid.effect" ];

    ASSERT_RETAIN(deferredEffect);
    ASSERT_RETAIN(projectedGridEffect);

    logLuminance
        = [ deferredEffect techniqueWithName:@"linear_sRGB_to_log_luminance" ];

    tonemap
        = [ deferredEffect techniqueWithName:@"tonemap_reinhard" ];

    ASSERT_RETAIN(logLuminance);
    ASSERT_RETAIN(tonemap);

    tonemapKey = [ deferredEffect variableWithName:@"key" ];
    tonemapAverageLuminanceLevel = [ deferredEffect variableWithName:@"averageLuminanceLevel" ];
    tonemapAdaptedAverageLuminance = [ deferredEffect variableWithName:@"adaptedAverageLuminance" ];
    tonemapWhiteLuminance = [ deferredEffect variableWithName:@"whiteLuminance" ];

    NSAssert(tonemapKey != nil && tonemapAverageLuminanceLevel != nil
             && tonemapAdaptedAverageLuminance != nil && tonemapWhiteLuminance != nil, @"");

    whitecapsPrecompute      = [ projectedGridEffect techniqueWithName:@"whitecaps_precompute" ];
    projectedGridTFTransform = [ projectedGridEffect techniqueWithName:@"proj_grid_tf_transform" ];
    projectedGridTFFeedback  = [ projectedGridEffect techniqueWithName:@"proj_grid_tf_feedback"  ];

    ASSERT_RETAIN(whitecapsPrecompute);
    ASSERT_RETAIN(projectedGridTFTransform);
    ASSERT_RETAIN(projectedGridTFFeedback);

    // transform feedback setup
    const char * tfposition = "out_position";
    const char * tfndposition = "out_non_disp_position";
    const char * varyings[2] = {tfposition, tfndposition};

    glTransformFeedbackVaryings([ projectedGridTFTransform glID ], 2, (const char **)(&varyings), GL_SEPARATE_ATTRIBS);
	glLinkProgram([ projectedGridTFTransform glID ]);

    NSError * tfLinkError = nil;
    BOOL result
        = [ NPEffectTechnique
                checkProgramLinkStatus:[ projectedGridTFTransform glID ]
                                 error:&tfLinkError ];

    if ( result == NO )
    {
        NPLOG_ERROR(tfLinkError);
    }

    NSAssert(result, @"Transform Feedback setup failed");

    varianceLUTLastResolutionIndex = ULONG_MAX;
    varianceLUTResolutionIndex = defaultVarianceLUTResolutionIndex;
    varianceRTC = [[ NPRenderTargetConfiguration alloc ] initWithName:@"Variance RTC" ];
    varianceLUT = [[ NPRenderTexture alloc ] initWithName:@"Variance LUT" ];

    variance = [ deferredEffect techniqueWithName:@"variance" ];
    ASSERT_RETAIN(variance);

    layer            = [ deferredEffect variableWithName:@"layer" ];
    deltaVariance    = [ deferredEffect variableWithName:@"deltaVariance" ];
    varianceTextureResolution = [ deferredEffect variableWithName:@"varianceTextureResolution" ];

    NSAssert(layer != nil && deltaVariance != nil
             && varianceTextureResolution != nil, @"");

    // fullscreen quad for render target display
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    DESTROY(entities);
    DESTROY(camera);
    DESTROY(axes);

    DESTROY(testCamera);
    DESTROY(testCameraFrustum);
    DESTROY(testProjectorFrustum);
    DESTROY(cameraFrustum);

    [ iwave stop ];
    [ ocean stop ];

    DESTROY(iwave);
    SAFE_DESTROY(ocean);
    SAFE_DESTROY(projectedGrid);
    SAFE_DESTROY(skylight);
    SAFE_DESTROY(file);

    DESTROY(variance);
    DESTROY(varianceLUT);
    DESTROY(varianceRTC);

    DESTROY(depthBuffer);
    DESTROY(logLuminanceTarget);
    DESTROY(linearsRGBTarget);
    DESTROY(rtc);

    DESTROY(whitecapsTarget);
    DESTROY(whitecapsRtc);

    DESTROY(fullscreenQuad);
    DESTROY(whitecapsPrecompute);
    DESTROY(projectedGridTFFeedback);
    DESTROY(projectedGridTFTransform);
    DESTROY(logLuminance);
    DESTROY(tonemap);
    DESTROY(deferredEffect);
    DESTROY(projectedGridEffect);

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    NSString * absoluteFileName
        = [[[ NPEngineCore instance ] 
                localPathManager ] getAbsolutePath:fileName ];

    if ( absoluteFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    NSDictionary * sceneContents
        = [ NSDictionary dictionaryWithContentsOfFile:absoluteFileName ];

    NSString * sceneName   = [ sceneContents objectForKey:@"Name"     ];
    NSArray  * entityFiles = [ sceneContents objectForKey:@"Entities" ];

    [ self setName:sceneName ];

    //[ ocean setCamera:testCamera ];
    [ ocean setCamera:camera ];

    [ projectedGrid setProjector:[ ocean projector ]];

    [ iwave start ];
    [ ocean start ];

    const NSUInteger numberOfEntityFiles = [ entityFiles count ];
    for ( NSUInteger i = 0; i < numberOfEntityFiles; i++ )
    {
        id <ODPEntity> entity
            = [ self loadEntityFromFile:[ entityFiles objectAtIndex:i ]
                                  error:NULL ];

        if ( entity != nil )
        {
            [ entities addObject:entity ];
        }
    }

    return YES;
}

- (ODCamera *) camera
{
    return camera;
}

- (ODPreethamSkylight *) skylight
{
    return skylight;
}

- (ODOceanEntity *) ocean
{
    return ocean;
}

- (void) update:(const double)frameTime
{
    deltaTime = frameTime;

    NPViewport * viewport = [[ NP Graphics] viewport ];
    currentResolution.x = [ viewport width  ];
    currentResolution.y = [ viewport height ];

    IVector2 r;
    r.x = currentResolution.x / 4;
    r.y = currentResolution.y / 4;
    [ projectedGrid setResolution:r ];

    /*
    if ( [ projector connecting ] == YES )
    {
        [ camera lockInput ];

        startOrientation = [ camera orientation ];
        endOrientation   = [ projector orientation ];

        startPosition = [ camera position ];
        endPosition   = [ projector position ];

        connecting = YES;
    }

    if ( [ projector disconnecting ] == YES )
    {
        disconnecting = YES;
    }

    if ( connecting == YES )
    {
        animationTime += frameTime;
        animationTime = MIN(animationTime, 1.0f);

        FQuaternion slerped = fquat_qqs_slerp(&startOrientation, &endOrientation, animationTime);
        FVector3 lerped = fv3_vvs_lerp(&startPosition, &endPosition, animationTime);

        [ camera setOrientation:slerped ];
        [ camera setPosition:lerped ];

        if ( animationTime == 1.0f )
        {
            connecting = NO;
            animationTime = 0.0f;
            [ camera unlockInput ];

            [ camera setYaw:[ projector yaw ]];
            [ camera setPitch:[ projector pitch ]];
        }
    }
    */

    [ camera        update:frameTime ];
    [ testCamera    update:frameTime ];

    [ skylight      update:frameTime ];
    [ ocean         update:frameTime ];
    //[ iwave         update:frameTime ];
    [ projectedGrid update:frameTime ];

    [ cameraFrustum updateWithPosition:[camera position]
                           orientation:[camera orientation]
                                   fov:[camera fov]
                             nearPlane:[camera nearPlane]
                              farPlane:[camera farPlane]
                           aspectRatio:[camera aspectRatio]];

    [ testCameraFrustum updateWithPosition:[testCamera position]
                               orientation:[testCamera orientation]
                                       fov:[testCamera fov]
                                 nearPlane:[testCamera nearPlane]
                                  farPlane:[testCamera farPlane]
                               aspectRatio:[testCamera aspectRatio]];

    [ testProjectorFrustum updateWithPosition:[[ ocean projector ] position]
                                  orientation:[[ ocean projector ] orientation]
                                          fov:[[ ocean projector ] fov]
                                    nearPlane:[[ ocean projector ] nearPlane]
                                     farPlane:[[ ocean projector ] farPlane]
                                  aspectRatio:[[ ocean projector ] aspectRatio]];

    /*
    const NSUInteger numberOfEntities = [ entities count ];
    for ( NSUInteger i = 0; i < numberOfEntities; i++ )
    {
        [[ entities objectAtIndex:i ] update:frameTime ];
    }
    */
}

- (void) render
{
    if (( currentResolution.x != lastFrameResolution.x )
          || ( currentResolution.y != lastFrameResolution.y ))
    {
        [ rtc setWidth:currentResolution.x  ];
        [ rtc setHeight:currentResolution.y ];

        NSAssert(([ self generateRenderTargets:NULL ] == YES), @"");

        lastFrameResolution = currentResolution;
    }

    BOOL forceSlopeVarianceUpdate = NO;
    if (varianceLUTResolutionIndex != varianceLUTLastResolutionIndex)
    {
        uint32_t varianceLUTRes = varianceLUTResolutions[varianceLUTResolutionIndex];

        [ varianceRTC setWidth:varianceLUTRes ];
        [ varianceRTC setHeight:varianceLUTRes ];

        NSAssert(([ self generateVarianceLUTRenderTarget:varianceLUTRes error:NULL ] == YES), @"");

        varianceLUTLastResolutionIndex = varianceLUTResolutionIndex;
        forceSlopeVarianceUpdate = YES;
    }

    if ( [ ocean updateSlopeVariance ] == YES || forceSlopeVarianceUpdate == YES )
    {
        [ self updateSlopeVarianceLUT:varianceLUTResolutions[varianceLUTResolutionIndex] ];
    }

    NPTexture2DArray * dispDerivatives = [ ocean displacementDerivatives ];
    const uint32_t dispDerivativesWidth  = [ dispDerivatives width  ];
    const uint32_t dispDerivativesHeight = [ dispDerivatives height ];
    const uint32_t dispDerivativesLayers = [ dispDerivatives layers ];
    const uint32_t whitecapsTargetWidth  = [ whitecapsTarget width  ];
    const uint32_t whitecapsTargetHeight = [ whitecapsTarget height ];
    const uint32_t whitecapsTargetLayers = [ whitecapsTarget depth  ];

    // 4 channels in dispDerivatives -> 2 channels in whitecapsTarget
    const uint32_t necessaryWhiteCapsTargetLayers
        = (dispDerivativesLayers / 2) + (dispDerivativesLayers % 2);

    if (( dispDerivativesWidth != 0 && dispDerivativesHeight != 0 )
        && (dispDerivativesWidth  != whitecapsTargetWidth
            || dispDerivativesHeight != whitecapsTargetHeight
            || necessaryWhiteCapsTargetLayers != whitecapsTargetLayers)
         )
    {
        BOOL result
            = [ whitecapsTarget
                    generate2DArray:NpRenderTargetColor
                              width:dispDerivativesWidth
                             height:dispDerivativesHeight
                             layers:necessaryWhiteCapsTargetLayers
                        pixelFormat:NpTexturePixelFormatRGBA
                         dataFormat:NpTextureDataFormatFloat32
                      mipmapStorage:YES
                              error:NULL ];

        NSAssert(result == YES, @"KABUMM");

        [ whitecapsRtc setWidth:dispDerivativesWidth ];
        [ whitecapsRtc setHeight:dispDerivativesHeight ];
        [ whitecapsRtc bindFBO ];

        for (uint32_t l = 0; l < necessaryWhiteCapsTargetLayers; l++)
        {
                [ whitecapsTarget
                        attachLevel:0
                              layer:l
          renderTargetConfiguration:whitecapsRtc
                   colorBufferIndex:l
                            bindFBO:NO ];

        }

        [ whitecapsRtc unbindFBO ];
    }

    NPStateConfiguration * stateConfiguration = [[ NP Graphics ] stateConfiguration ];

    NPCullingState * cullingState         = [ stateConfiguration cullingState     ];
    NPBlendingState * blendingState       = [ stateConfiguration blendingState    ];
    NPDepthTestState * depthTestState     = [ stateConfiguration depthTestState   ];
    NPPolygonFillState * fillState        = [ stateConfiguration polygonFillState ];
    NPStencilTestState * stencilTestState = [ stateConfiguration stencilTestState ];

    // deactivate culling, depth write and depth test
    [ blendingState  setEnabled:NO ];
    [ cullingState   setEnabled:NO ];
    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    // reset all matrices
    [[[ NP Core ] transformationState ] reset ];

    /*
    // precompute whitecaps derivative stuff
    [ whitecapsRtc activate ];

    NSError * wce = nil;
    if ( [ whitecapsRtc checkFrameBufferCompleteness:&wce ] == NO )
    {
        NPLOG_ERROR(wce);
    }

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean displacementDerivatives ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    NPEffectVariableFloat * ds = [ projectedGridEffect variableWithName:@"displacementScale"];
    [ ds setValue:[ ocean displacementScale ]];

    [ whitecapsPrecompute activate ];
    [ fullscreenQuad render ];

    [ whitecapsRtc deactivate ];

    // Generate whhitecaps derivative stuff mipmaps
    [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ whitecapsTarget texture ] ];
    glGenerateMipmap(GL_TEXTURE_2D);
    [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];
    */

    // setup linear sRGB target
    [ rtc bindFBO ];
    [ linearsRGBTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

    [ depthBuffer
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    [ depthTestState setWriteEnabled:YES ];
    [ stateConfiguration activate ];
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ skylight skylightTexture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    NPEffectVariableFloat3 * dcp = [ deferredEffect variableWithName:@"cameraPosition"];
    [ dcp setValue:[camera position ]];
    [[ deferredEffect techniqueWithName:@"skylight"] activate ];
    const FVector3 * const frustumP = [ cameraFrustum frustumCornerPositions ];
    glBegin(GL_QUADS);
        glVertexAttrib3f(NpVertexStreamTexCoords, frustumP[4].x, frustumP[4].y, frustumP[4].z);
        glVertexAttrib2f(NpVertexStreamPositions, -1.0f, -1.0f);
        glVertexAttrib3f(NpVertexStreamTexCoords, frustumP[5].x, frustumP[5].y, frustumP[5].z);
        glVertexAttrib2f(NpVertexStreamPositions,  1.0f, -1.0f);
        glVertexAttrib3f(NpVertexStreamTexCoords, frustumP[6].x, frustumP[6].y, frustumP[6].z);
        glVertexAttrib2f(NpVertexStreamPositions,  1.0f,  1.0f);
        glVertexAttrib3f(NpVertexStreamTexCoords, frustumP[7].x, frustumP[7].y, frustumP[7].z);
        glVertexAttrib2f(NpVertexStreamPositions, -1.0f,  1.0f);
    glEnd();

    [ camera render ];

    // activate culling, depth write and depth test
    [ blendingState  setEnabled:NO ];
    [ cullingState   setCullFace:NpCullfaceBack ];
    [ cullingState   setEnabled:YES ];
    [ depthTestState setWriteEnabled:YES ];
    [ depthTestState setEnabled:YES ];
    [ stateConfiguration activate ];
    
    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean heightfield  ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean displacement ] texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean sizes ]        texelUnit:2 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    NPEffectVariableMatrix4x4 * v = [ deferredEffect variableWithName:@"invMVP"];
    [ v setValue:[[ ocean projector ] inverseViewProjection]];

    NPEffectVariableMatrix4x4 * w = [ projectedGridEffect variableWithName:@"invMVP"];
    NPEffectVariableFloat * a = [ projectedGridEffect variableWithName:@"areaScale"];
    NPEffectVariableFloat * hs = [ projectedGridEffect variableWithName:@"heightScale"];
    NPEffectVariableFloat * je = [ projectedGridEffect variableWithName:@"jacobianEpsilon"];
    NPEffectVariableFloat3 * cP = [ projectedGridEffect variableWithName:@"cameraPosition"];
    NPEffectVariableFloat3 * dsP = [ projectedGridEffect variableWithName:@"directionToSun"];
    NPEffectVariableFloat3 * scP = [ projectedGridEffect variableWithName:@"sunColor"];
    NPEffectVariableFloat2 * wcP = [ projectedGridEffect variableWithName:@"waterColorCoordinate"];
    NPEffectVariableFloat2 * wciP = [ projectedGridEffect variableWithName:@"waterColorIntensityCoordinate"];
    NPEffectVariableFloat2 * vsP = [ projectedGridEffect variableWithName:@"vertexStep"];
    NPEffectVariableFloat * ds = [ projectedGridEffect variableWithName:@"displacementScale"];

    NSAssert(w != nil && a != nil && ds != nil && hs != nil && je != nil && cP != nil && dsP != nil && scP != nil && vsP != nil && wcP != nil && wciP != nil, @"");

    [ ds setValue:[ ocean displacementScale ]];
    [ w setValue:[[ ocean projector ] inverseViewProjection]];
    [ a setValue:[ocean areaScale ]];
    [ hs setValue:[ ocean heightScale ]];
    [ je setValue:jacobianEpsilon ];
    [ cP setValue:[ camera position ]];
    [ dsP setValue:[ skylight directionToSun ]];
    [ scP setValue:[ skylight sunColor ]];
    [ wcP setValue:[ ocean waterColorCoordinate ]];
    [ wciP setValue:[ ocean waterColorIntensityCoordinate ]];
    [ vsP setValue:[ projectedGrid vertexStep ]];

    [ projectedGridTFTransform activate ];
    [ projectedGrid renderTFTransform ];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean gradient ]            texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean waterColor ]          texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean waterColorIntensity ] texelUnit:2 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean sizes ]               texelUnit:3 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ varianceLUT texture ]       texelUnit:4 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ skylight skylightTexture ]  texelUnit:5 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ whitecapsTarget texture  ]  texelUnit:6 ];
    [[[ NP Graphics ] textureBindingState ] activate ];


    [ projectedGridTFFeedback activate ];
    [ projectedGrid renderTFFeedback  ];

    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];

    [ cullingState setEnabled:NO ];
    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    const Vector3 directionToSun = [ skylight directionToSun ];
    const float length = [ axes axisLength ];

    glLineWidth(4.0);
    [[ deferredEffect techniqueWithName:@"v3c3" ] activate ];
    [ axes render ];
    glBegin(GL_LINES);
        glVertexAttrib3f(NpVertexStreamColors, 1.0f, 1.0f, 0.0f);
        glVertexAttrib3f(NpVertexStreamPositions, 0.0f, 0.0f, 0.0f);
        glVertexAttrib3f(NpVertexStreamPositions, directionToSun.x * length, directionToSun.y * length, directionToSun.z * length);
    glEnd();
    glLineWidth(1.0);

    [ linearsRGBTarget detach:NO ];
    [ depthBuffer      detach:NO ];

    // log luminance computation for tonemapping
    [ logLuminanceTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

    // disable culling, blending, depthwrite, depthtest
    [ blendingState  setEnabled:NO ];
    [ cullingState   setEnabled:NO ];
    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ linearsRGBTarget texture ] texelUnit:0 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];
    [ logLuminance activate ];

    [ fullscreenQuad render ];

    [ logLuminanceTarget detach:NO ];
    [ rtc deactivate ];

    // clear back buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // generate logluminance mipmap pyramid
    // highest level contains average log luminance
    [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ logLuminanceTarget texture ] ];
    glGenerateMipmap(GL_TEXTURE_2D);

    const int32_t numberOfLevels
        = 1 + (int32_t)floor(logb(MAX(currentResolution.x, currentResolution.y)));

    Half averageLogLuminance = 0;
    glGetTexImage(GL_TEXTURE_2D, numberOfLevels - 1, GL_RED, GL_HALF_FLOAT, &averageLogLuminance);
    double averageLuminance = exp(half_to_float(averageLogLuminance));

    // "Perceptual effects in real-time tone mapping - Krawczyk 2005"
    // 2.3 scoptic vision
    double rodSensitivity = 0.04 / (0.04 + averageLuminance); // eq 7
    // 2.2 temporal luminance adaptation
    double adaptationConstantRods = 0.4; // eq 6
    double adaptationConstantCones = 0.1; // eq 6
    // 3.2 temporal luminance adaptation
    double adaptationConstant = adaptationConstantRods * rodSensitivity + (1.0 - rodSensitivity) * adaptationConstantCones; // eq 12
    // 2.2 temporal luminance adaptation
    double adaptedLuminance
        = lastAdaptedLuminance
          + (averageLuminance - lastAdaptedLuminance)
          * (1.0 - exp(-(deltaTime / adaptationConstant))); // eq 5

    // 3.1 Key value
    double automaticKey = 1.03 - (2.0 / (2.0 + log10(adaptedLuminance + 1.0))); // eq 11

    lastAdaptedLuminance = adaptedLuminance;

    [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

    [[[ NP Graphics ] textureBindingState ] setTexture:[ linearsRGBTarget   texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ logLuminanceTarget texture ] texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    [ tonemapKey setValue:automaticKey ];
    [ tonemapWhiteLuminance setValue:referenceWhite ];
    [ tonemapAverageLuminanceLevel setValue:(numberOfLevels - 1) ];
    [ tonemapAdaptedAverageLuminance setValue:adaptedLuminance ];

    [ tonemap activate ];
    [ fullscreenQuad render ];

    [ stateConfiguration deactivate ];
}

@end
