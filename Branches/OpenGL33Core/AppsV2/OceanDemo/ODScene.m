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
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
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
#import "ODVariance.h"
#import "ODScene.h"

static const NSUInteger defaultVarianceLUTResolutionIndex = 0;
static const uint32_t varianceLUTResolutions[4] = {4, 8, 12, 16};


@interface ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
                                     ;

- (BOOL) generateRenderTargets:(NSError **)error;

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

@end

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

    entities  = [[ NSMutableArray alloc ] init ];

    camera = [[ ODCamera alloc ] init ];
    cameraFrustum = [[ ODFrustum alloc ] initWithName:@"CFrustum" ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"ProjGrid" ];
    ocean = [[ ODOceanEntity alloc ] initWithName:@"Ocean" ];
	skylight = [[ ODPreethamSkylight alloc ] init ];
	axes = [[ ODWorldCoordinateAxes alloc ] init ];

    // camera animation
    fquat_set_identity(&startOrientation);
    fquat_set_identity(&endOrientation);
    fv3_v_init_with_zeros(&startPosition);
    fv3_v_init_with_zeros(&endPosition);
    animationTime = 0.0f;
    connecting = NO;
    disconnecting = NO;

    oceanAsGrid = NO;

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
    lastDispDerivativesLayers = UINT_MAX;

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
    const char * tfposition = "out_ws_position";
    const char * tfndposition = "out_ws_non_disp_position";
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

    transformAreaScale = [ projectedGridEffect variableWithName:@"areaScale" ];
    transformDisplacementScale = [ projectedGridEffect variableWithName:@"displacementScale" ];
    transformHeightScale = [ projectedGridEffect variableWithName:@"heightScale" ];
    transformVertexStep = [ projectedGridEffect variableWithName:@"vertexStep" ];
    transformInvMVP = [ projectedGridEffect variableWithName:@"invMVP" ];

    NSAssert(transformAreaScale != nil && transformDisplacementScale != nil
             && transformHeightScale != nil && transformVertexStep != nil
             && transformInvMVP != nil, @"");

    feedbackSunColor = [ projectedGridEffect variableWithName:@"sunColor" ];
    feedbackSkyIrradiance = [ projectedGridEffect variableWithName:@"skyIrradiance" ];
    feedbackCameraPosition = [ projectedGridEffect variableWithName:@"cameraPosition" ];
    feedbackDirectionToSun = [ projectedGridEffect variableWithName:@"directionToSun" ];
    feedbackJacobianEpsilon = [ projectedGridEffect variableWithName:@"jacobianEpsilon" ];

    feedbackWaterColorCoordinate
        = [ projectedGridEffect variableWithName:@"waterColorCoordinate" ];

    feedbackWaterColorIntensityCoordinate
        = [ projectedGridEffect variableWithName:@"waterColorIntensityCoordinate" ];

    NSAssert(feedbackSunColor != nil && feedbackSkyIrradiance != nil
             && feedbackCameraPosition != nil && feedbackDirectionToSun != nil
             && feedbackJacobianEpsilon != nil && feedbackWaterColorCoordinate != nil
             && feedbackWaterColorIntensityCoordinate != nil,
             @"");

    variance = [[ ODVariance alloc ] initWithName:@"Ocean Variance" ocean:ocean ];

    // fullscreen quad for render target display
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    screenshotAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"Screenshot" inputEvent:NpKeyboardS ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    DESTROY(entities);
    DESTROY(camera);
    DESTROY(axes);

    DESTROY(cameraFrustum);

    [ ocean stop ];

    SAFE_DESTROY(ocean);
    SAFE_DESTROY(projectedGrid);
    SAFE_DESTROY(skylight);
    SAFE_DESTROY(file);

    DESTROY(variance);

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

    [[[ NP Input ] inputActions ] removeInputAction:screenshotAction ];

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

    [ ocean setCamera:camera ];
    [ projectedGrid setProjector:[ ocean projector ]];
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
    [ skylight      update:frameTime ];
    [ ocean         update:frameTime ];
    [ projectedGrid update:frameTime ];

    [ cameraFrustum updateWithPosition:[camera position]
                           orientation:[camera orientation]
                                   fov:[camera fov]
                             nearPlane:[camera nearPlane]
                              farPlane:[camera farPlane]
                           aspectRatio:[camera aspectRatio]];

    [ variance update ];
    /*
    const NSUInteger numberOfEntities = [ entities count ];
    for ( NSUInteger i = 0; i < numberOfEntities; i++ )
    {
        [[ entities objectAtIndex:i ] update:frameTime ];
    }
    */
}

static NSString * date_string()
{
    tzset();
    time_t t = time(NULL);

    if (t == ((time_t)-1))
    {
        return nil;
    }

    struct tm now;
    if (localtime_r(&t, &now) == NULL)
    {
        return nil;
    }

    char dateBuffer[256] = {0};

    if (strftime(dateBuffer, sizeof(dateBuffer), "%d-%m-%Y_%H-%M-%S", &now) == 0)
    {
        return nil;
    }

    return [ NSString stringWithUTF8String:dateBuffer ];
}

static bool texture_to_pfm(NPTexture2D * texture, NSString* dateString, NSString * suffix)
{
    const uint32_t width  = [ texture width  ];
    const uint32_t height = [ texture height ];

    float* screenShotBuffer = ALLOC_ARRAY(float, width * height * 3);

    [[[ NP Graphics ] textureBindingState ] setTextureImmediately:texture ];
    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGB, GL_FLOAT, screenShotBuffer);
    [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

    NSString * filename = [[ dateString stringByAppendingString:suffix ] stringByAppendingPathExtension:@"pfm" ];
    NSLog(filename);
    FILE * pfm = fopen([ filename UTF8String ], "wb");

    if (pfm == NULL)
    {
        return false;
    }

    // RGB
    fprintf(pfm, "PF\n");
    // resolution
    fprintf(pfm, "%u %u\n", width, height);
    // little endian
    fprintf(pfm, "-1.0\n");

    size_t bufferSize = sizeof(float) * (size_t)width * (size_t)height * (size_t)3;
    size_t written = fwrite(screenShotBuffer, 1, bufferSize, pfm);

    fclose(pfm);
    FREE(screenShotBuffer);

    return true;
}

- (void) updateMainRenderTargetResolution
{
    if (( currentResolution.x != lastFrameResolution.x )
          || ( currentResolution.y != lastFrameResolution.y ))
    {
        [ rtc setWidth:currentResolution.x  ];
        [ rtc setHeight:currentResolution.y ];

        NSAssert(([ self generateRenderTargets:NULL ] == YES), @"");

        lastFrameResolution = currentResolution;
    }
}

- (void) updateWhitecapsRenderTargetResolution
{
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
        && ( dispDerivativesWidth  != whitecapsTargetWidth
             || dispDerivativesHeight != whitecapsTargetHeight
             || dispDerivativesLayers != lastDispDerivativesLayers ))
    {
        NSAssert(dispDerivativesLayers > 0 && dispDerivativesLayers <= 4, @"");
        lastDispDerivativesLayers = dispDerivativesLayers;

        BOOL result
            = [ whitecapsTarget
                    generate2DArray:NpRenderTargetColor
                              width:dispDerivativesWidth
                             height:dispDerivativesHeight
                             layers:2
                        pixelFormat:NpTexturePixelFormatRGBA
                         dataFormat:NpTextureDataFormatFloat32
                      mipmapStorage:YES
                              error:NULL ];

        NSAssert(result == YES, @"");

        [ whitecapsRtc setWidth:dispDerivativesWidth ];
        [ whitecapsRtc setHeight:dispDerivativesHeight ];
        [ whitecapsRtc bindFBO ];

        // Attach each layer as a render target, so we can clear
        // all layers at one
        for (uint32_t l = 0; l < 2; l++)
        {
            [ whitecapsTarget attachLevel:0
                                    layer:l
                renderTargetConfiguration:whitecapsRtc
                         colorBufferIndex:l
                                  bindFBO:NO ];

        }

        [ whitecapsRtc activateDrawBuffers ];
        [ whitecapsRtc activateViewport ];

        NSError * wce = nil;
        if ( [ whitecapsRtc checkFrameBufferCompleteness:&wce ] == NO )
        {
            NPLOG_ERROR(wce);
        }

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

        [ whitecapsRtc deactivate ];
    }
}

- (void) whitecapsPrecompute
{
    NPTexture2DArray * dispDerivatives = [ ocean displacementDerivatives ];
    const uint32_t dispDerivativesWidth  = [ dispDerivatives width  ];
    const uint32_t dispDerivativesHeight = [ dispDerivatives height ];

    if ( dispDerivativesWidth == 0 || dispDerivativesHeight == 0 )
    {
        return;
    }

    // precompute whitecaps derivative stuff
    [ whitecapsRtc activate ];

    NSError * wce = nil;
    if ( [ whitecapsRtc checkFrameBufferCompleteness:&wce ] == NO )
    {
        NPLOG_ERROR(wce);
    }

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:dispDerivatives texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    [ transformDisplacementScale setValue:[ocean displacementScale ]];

    [ whitecapsPrecompute activate ];
    [ fullscreenQuad render ];

    [ whitecapsRtc deactivate ];

    // Generate whhitecaps derivative stuff mipmaps
    [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ whitecapsTarget texture ] ];
    glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
    [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) renderScene:(NPEffectTechnique *) oceanTechnique
               lines:(BOOL) oceanAsLines
{
    // get state related objects for later use
    NPStateConfiguration * stateConfiguration = [[ NP Graphics ] stateConfiguration ];

    NPCullingState * cullingState         = [ stateConfiguration cullingState     ];
    NPBlendingState * blendingState       = [ stateConfiguration blendingState    ];
    NPDepthTestState * depthTestState     = [ stateConfiguration depthTestState   ];
    NPPolygonFillState * fillState        = [ stateConfiguration polygonFillState ];
    NPStencilTestState * stencilTestState = [ stateConfiguration stencilTestState ];

    // reset all matrices
    [[[ NP Core ] transformationState ] reset ];

    // make depth buffer writeable, otherwise we cannot clear it
    [ depthTestState setWriteEnabled:YES ];
    [ stateConfiguration activate ];
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // render sky on farplane
    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ skylight skylightTexture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    // now the serious stuff starts
    [ camera render ];

    NPEffectVariableFloat3 * dcp = [ deferredEffect variableWithName:@"cameraPosition"];
    [ dcp setValue:[camera position ]];
    [[ deferredEffect techniqueWithName:@"skylight"] activate ];
    const FVector3 * const frustumP = [ cameraFrustum frustumCornerPositions ];
    glBegin(GL_QUADS);
        glVertexAttrib2f(NpVertexStreamPositions, -1.0f, -1.0f);
        glVertexAttrib2f(NpVertexStreamPositions,  1.0f, -1.0f);
        glVertexAttrib2f(NpVertexStreamPositions,  1.0f,  1.0f);
        glVertexAttrib2f(NpVertexStreamPositions, -1.0f,  1.0f);
    glEnd();

    // activate culling, depth write and depth test
    [ blendingState  setEnabled:NO ];
    [ cullingState   setCullFace:NpCullfaceBack ];
    [ cullingState   setEnabled:YES ];
    [ depthTestState setWriteEnabled:YES ];
    [ depthTestState setEnabled:YES ];
    [ stateConfiguration activate ];

    // bind all ocean data necessary for per-vertex and for per-pixel computations
    [[[ NP Graphics ] textureBindingState ] clear ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean sizes ]               texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean heightfield  ]        texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean displacement ]        texelUnit:2 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean gradient ]            texelUnit:3 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean waterColor ]          texelUnit:4 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean waterColorIntensity ] texelUnit:5 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ variance texture ]          texelUnit:6 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ skylight skylightTexture ]  texelUnit:7 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ whitecapsTarget texture  ]  texelUnit:8 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    [ transformAreaScale setValue:[ocean areaScale ]];
    [ transformDisplacementScale setValue:[ocean displacementScale ]];
    [ transformHeightScale setValue:[ocean heightScale ]];
    [ transformVertexStep setValue:[ projectedGrid vertexStep ]];
    [ transformInvMVP setValue:[[ ocean projector ] inverseViewProjection]];

    [ feedbackJacobianEpsilon setValue:jacobianEpsilon ];
    [ feedbackCameraPosition setValue:[ camera position ]];
    [ feedbackDirectionToSun setValue:[ skylight directionToSun ]];
    [ feedbackSunColor setValue:[ skylight sunColor ]];
    [ feedbackSkyIrradiance setValue:[skylight irradiance ]];
    [ feedbackWaterColorCoordinate setValue:[ ocean waterColorCoordinate ]];
    [ feedbackWaterColorIntensityCoordinate setValue:[ ocean waterColorIntensityCoordinate ]];

    // transform feedback starts here

    // transform step
    [ projectedGridTFTransform activate ];
    [ projectedGrid renderTFTransform ];

    if ( oceanAsLines == YES )
    {
        [ fillState setFrontFaceFill:NpPolygonFillLine ];
        [ fillState activate ];
    }

    // feedback step
    [ oceanTechnique activate ];
    [ projectedGrid renderTFFeedback  ];

    if (oceanAsLines == YES )
    {
        [ fillState setFrontFaceFill:NpPolygonFillFace ];
        [ fillState activate ];
    }

    // render world coordinate system axes
    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];

    [ cullingState setEnabled:NO ];
    [ depthTestState setWriteEnabled:NO ];
    [ depthTestState setEnabled:NO ];
    [ stateConfiguration activate ];

    [ axes setDirectionToSun: [ skylight directionToSun ]];
    [[ deferredEffect techniqueWithName:@"v3c3" ] activate ];
    [ axes render ];
}

- (void) render
{
    // get state related objects for later use
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

    // update main render target resolution
    [ self updateMainRenderTargetResolution ];

    // update whitecaps target resolution if necessary
    [ self updateWhitecapsRenderTargetResolution ];

    // generate whitecaps related data
    [ self whitecapsPrecompute ];

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

    // render sky, ocean, world space coordinate axes
    [ self renderScene:projectedGridTFFeedback lines:oceanAsGrid ];

    // detach targets
    [ linearsRGBTarget detach:NO ];
    [ depthBuffer      detach:NO ];

    // Tone mapping

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

    // log luminance computation for tonemapping
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

    //[ tonemapKey setValue:automaticKey ];
    [ tonemapKey setValue:key ];
    [ tonemapWhiteLuminance setValue:referenceWhite ];
    [ tonemapAverageLuminanceLevel setValue:(numberOfLevels - 1) ];
    [ tonemapAdaptedAverageLuminance setValue:adaptedLuminance ];

    [ tonemap activate ];
    [ fullscreenQuad render ];

    [ stateConfiguration deactivate ];

    if ([ screenshotAction deactivated ] == YES )
    {
        NSString * dateString = date_string();

        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_complete");

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

        [ self renderScene:[ projectedGridEffect techniqueWithName:@"ross" ] lines:NO];
        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_ross");
        [ self renderScene:[ projectedGridEffect techniqueWithName:@"sky" ] lines:NO];
        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_sky");
        [ self renderScene:[ projectedGridEffect techniqueWithName:@"sky" ] lines:YES];
        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_grid");
        [ self renderScene:[ projectedGridEffect techniqueWithName:@"sea" ] lines:NO];
        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_sea");
        [ self renderScene:[ projectedGridEffect techniqueWithName:@"whitecaps" ] lines:NO];
        texture_to_pfm([ linearsRGBTarget texture ], dateString, @"_whitecaps");

        // detach targets
        [ linearsRGBTarget detach:NO ];
        [ depthBuffer      detach:NO ];
    }
}

@end
