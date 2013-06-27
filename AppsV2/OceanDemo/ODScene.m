#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Geometry/NPFullscreenQuad.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/RenderTarget/NPRenderBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/State/NpState.h"
#import "Graphics/NPViewport.h"
#import "NP.h"
#import "Entities/ODBasePlane.h"
#import "Entities/ODPEntity.h"
#import "Entities/ODCamera.h"
#import "Entities/ODFrustum.h"
#import "Entities/ODProjector.h"
#import "Entities/ODProjectedGrid.h"
#import "Entities/ODPreethamSkylight.h"
#import "Entities/ODOceanEntity.h"
#import "Entities/ODEntity.h"
#import "ODScene.h"

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
        = [ positionsTarget generate:NpRenderTargetColor
                               width:currentResolution.x
                              height:currentResolution.y
                         pixelFormat:NpTexturePixelFormatRGBA
                          dataFormat:NpTextureDataFormatFloat32
                       mipmapStorage:NO
                               error:error ];

    result
        = result && [ normalsTarget generate:NpRenderTargetColor
                                       width:currentResolution.x
                                      height:currentResolution.y
                                 pixelFormat:NpTexturePixelFormatRGBA
                                  dataFormat:NpTextureDataFormatFloat16
                               mipmapStorage:NO
                                       error:error ];

    result
        = result && [ depthTarget generate:NpRenderTargetDepthStencil
                                     width:currentResolution.x
                                    height:currentResolution.y
                               pixelFormat:NpTexturePixelFormatDepthStencil
                                dataFormat:NpTextureDataFormatUInt32N
                             mipmapStorage:NO
                                     error:error ];

    return result;
}

@end

static const OdCameraMovementEvents testCameraMovementEvents
    = {.rotate  = NpKeyboardG, .strafe   = NpInputEventUnknown,
       .forward = NpInputEventUnknown, .backward = NpInputEventUnknown };

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
    testProjector = [[ ODProjector alloc ] initWithName:@"TestProj" ];

    [ testCamera setFarPlane:50.0 ];
    [ testProjector setCamera:testCamera ];

    testCameraFrustum = [[ ODFrustum alloc ] initWithName:@"CFrustum" ];
    testProjectorFrustum = [[ ODFrustum alloc ] initWithName:@"PFrustum" ];

    ocean = [[ ODOceanEntity alloc ] initWithName:@"Ocean" ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"ProjGrid" ];

    // camera animation
    fquat_set_identity(&startOrientation);
    fquat_set_identity(&endOrientation);
    fv3_v_init_with_zeros(&startPosition);
    fv3_v_init_with_zeros(&endPosition);
    animationTime = 0.0f;
    connecting = NO;
    disconnecting = NO;

    // tonemapping parameters
    referenceWhite = 1.0f;
    key = 0.72f;
    adaptationTimeScale = 10.0f;
    lastFrameLuminance = currentFrameLuminance = 1.0f;

    // render target resolution
    lastFrameResolution.x = lastFrameResolution.y = INT_MAX;
    currentResolution.x = currentResolution.y = 0;

    // g buffer
    gBuffer = [[ NPRenderTargetConfiguration alloc ] initWithName:@"GBUffer" ];
    positionsTarget = [[ NPRenderTexture alloc ] init ];
    normalsTarget   = [[ NPRenderTexture alloc ] init ];
    depthTarget     = [[ NPRenderTexture alloc ] init ];

    deferredEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"deferred.effect" ];

    ASSERT_RETAIN(deferredEffect);

    heightfieldMinMax = [ deferredEffect variableWithName:@"heightfieldMinMax" ];
    lightDirection    = [ deferredEffect variableWithName:@"lightDirection" ];
    cameraPosition    = [ deferredEffect variableWithName:@"cameraPosition" ];

    NSAssert(heightfieldMinMax != nil, @"heightfieldMinMax invalid");
    NSAssert(lightDirection != nil, @"lightDirection invalid");
    NSAssert(cameraPosition != nil, @"cameraPosition invalid");

    // fullscreen quad for render target display
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    DESTROY(entities);
    DESTROY(camera);

    DESTROY(testCamera);
    DESTROY(testProjector);
    DESTROY(testCameraFrustum);
    DESTROY(testProjectorFrustum);

    [ ocean stop ];
    SAFE_DESTROY(ocean);
    SAFE_DESTROY(projectedGrid);
    SAFE_DESTROY(skylight);
    SAFE_DESTROY(file);

    DESTROY(depthTarget);
    DESTROY(positionsTarget);
    DESTROY(normalsTarget);
    DESTROY(gBuffer);

    DESTROY(fullscreenQuad);
    DESTROY(deferredEffect);

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

    NSString * sceneName          = [ sceneContents objectForKey:@"Name"     ];
    NSString * skylightEntityFile = [ sceneContents objectForKey:@"Skylight" ];
    NSArray  * entityFiles        = [ sceneContents objectForKey:@"Entities" ];

    [ self setName:sceneName ];

    skylight = [ self loadEntityFromFile:skylightEntityFile error:NULL ];

    ASSERT_RETAIN(skylight);

    [ skylight  setCamera:camera ];
    [ ocean     setCamera:camera ];

    //[ projectedGrid setProjector:[ ocean projector ]];
    [ projectedGrid setProjector:testProjector ];

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
    NPViewport * viewport = [[ NP Graphics] viewport ];
    currentResolution.x = [ viewport width  ];
    currentResolution.y = [ viewport height ];

    IVector2 r;
    r.x = 200;
    r.y = 150;
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
    [ testProjector update:frameTime ];

    [ testCameraFrustum updateWithPosition:[testCamera position]
                               orientation:[testCamera orientation]
                                       fov:[testCamera fov]
                                 nearPlane:[testCamera nearPlane]
                                  farPlane:[testCamera farPlane]
                               aspectRatio:[testCamera aspectRatio]];

    [ testProjectorFrustum updateWithPosition:[testProjector position]
                                  orientation:[testProjector orientation]
                                          fov:[testProjector fov]
                                    nearPlane:[testProjector nearPlane]
                                     farPlane:[testProjector farPlane]
                                  aspectRatio:[testProjector aspectRatio]];

/*
    [ skylight      update:frameTime ];
*/
    [ ocean         update:frameTime ];
    [ projectedGrid update:frameTime ];

    const NSUInteger numberOfEntities = [ entities count ];
    for ( NSUInteger i = 0; i < numberOfEntities; i++ )
    {
        //[[ entities objectAtIndex:i ] update:frameTime ];
    }
}

- (void) render
{
    if (( currentResolution.x != lastFrameResolution.x )
          || ( currentResolution.y != lastFrameResolution.y ))
    {
        [ gBuffer setWidth:currentResolution.x  ];
        [ gBuffer setHeight:currentResolution.y ];

        NSAssert(([ self generateRenderTargets:NULL ] == YES), @"");

        lastFrameResolution = currentResolution;
    }

    NPCullingState * cullingState = [[[ NP Graphics ] stateConfiguration ] cullingState ];
    NPBlendingState * blendingState = [[[ NP Graphics ] stateConfiguration ] blendingState ];
    NPDepthTestState * depthTestState = [[[ NP Graphics ] stateConfiguration ] depthTestState ];
    NPPolygonFillState * fillState = [[[ NP Graphics ] stateConfiguration ] polygonFillState ];
    NPStencilTestState * stencilTestState = [[[ NP Graphics ] stateConfiguration ] stencilTestState ];

    // activate culling, depth write and depth test
    [ blendingState  setEnabled:NO ];
    [ cullingState   setCullFace:NpCullfaceBack ];
    [ cullingState   setEnabled:NO ];
    [ depthTestState setWriteEnabled:YES ];
    [ depthTestState setEnabled:YES ];
    //[ fillState      setFrontFaceFill:NpPolygonFillLine ];
    //[ fillState      setBackFaceFill:NpPolygonFillLine ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    // clear back buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ camera render ];

    [[[ NP Core] transformationState] resetModelMatrix];
    /*
    NPEffectVariableFloat2 * v = [ deferredEffect variableWithName:@"scale"];
    [ v setFValue:[ocean baseMeshScale]];
    [[ deferredEffect techniqueWithName:@"base_xz" ] activate ];
    [ ocean renderBaseMesh ];
    */
        
    NPEffectVariableMatrix4x4 * v = [ deferredEffect variableWithName:@"invMVP"];
    [ v setValue:[testProjector inverseViewProjection]];
    
    [[ deferredEffect techniqueWithName:@"proj_grid_corners" ] activate ];
    [ projectedGrid render:nil ];
    
    
    //[ ocean renderBasePlane ];

    [ NPEffectTechnique deactivate ];

    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] blendingState ] setBlendingMode:NpBlendingAverage ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] blendingState ] activate ];

    [[[[ NPEngineGraphics instance ] stateConfiguration ] cullingState ] setEnabled:NO ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] cullingState ] activate ];

    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] activate ];

    FVector4 fc = {0.0f, 1.0f, 0.0f, 0.5f};
    FVector4 lc = {1.0f, 0.0f, 0.0f, 0.5f};

    NPEffectVariableFloat4 * c = [ deferredEffect variableWithName:@"color" ];
    NSAssert(c != nil, @"");

    [ c setFValue:fc ];
    [[ deferredEffect techniqueWithName:@"color" ] activate ];

    [ testCameraFrustum render ];

    [ c setFValue:lc ];
    [[ deferredEffect techniqueWithName:@"color" ] activate ];

    [ testProjectorFrustum render ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];

    /*
    [ gBuffer bindFBO ];

    // attach G-Buffer positions target texture
    [ positionsTarget
        attachToRenderTargetConfiguration:gBuffer
                         colorBufferIndex:0
                                  bindFBO:NO ];

    // attach G-Buffer normals target texture
    [ normalsTarget
        attachToRenderTargetConfiguration:gBuffer
                         colorBufferIndex:1
                                  bindFBO:NO ];

    // attach depth stencil target texture
    [ depthTarget
        attachToRenderTargetConfiguration:gBuffer
                         colorBufferIndex:0
                                  bindFBO:NO ];

    // configure draw buffers
    [ gBuffer activateDrawBuffers ];

    // set viewport
    [ gBuffer activateViewport ];

    // check FBO completeness
    NSError * fboError = nil;
    if ([ gBuffer checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }

    // make stencil buffer writable before clearing
    [ stencilTestState setWriteEnabled:YES ];

    // clear G-Buffer
    // [[ NP Graphics ] clearFrameBuffer:NO depthBuffer:YES stencilBuffer:YES ];
    const FVector4 v = (FVector4){FLT_MAX, FLT_MAX, FLT_MAX, FLT_MAX};
    [[ NP Graphics ] clearDepthBuffer:1.0f stencilBuffer:0 ];
    [[ NP Graphics ] clearDrawBuffer:0 color:v ];
    [[ NP Graphics ] clearDrawBuffer:1 color:v ];

    // set up view and projection matrices
    [ camera render ];

    //
    NPEffectTechnique * t = [ deferredEffect techniqueWithName:@"geometry" ];
    [ t lock ];
    [ t activate:YES ];
    */

    /*
    [ stencilTestState setComparisonFunction:NpComparisonAlways ];
    [ stencilTestState setOperationOnStencilTestFail:NpStencilKeepValue ];
    [ stencilTestState setOperationOnDepthTestFail:NpStencilKeepValue ];
    [ stencilTestState setOperationOnDepthTestPass:NpStencilIncrementValue ];
    [ stencilTestState setEnabled:YES ];
    [ stencilTestState activate ];
    */

    /*
    glBegin(GL_QUADS);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(0.0f, 0.0f, 5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(10.0f, 0.0f, 5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(10.0f, 10.0f, 5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(0.0f, 10.0f, 5.0f);
    glEnd();

    glBegin(GL_QUADS);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(0.0f, 0.0f, -5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(10.0f, 0.0f, -5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(10.0f, 10.0f, -5.0f);
        glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 0.0f, 1.0f);
        glVertex3f(0.0f, 10.0f, -5.0f);
    glEnd();

    [ entities makeObjectsPerformSelector:@selector(render) ];

    [ ocean renderBasePlane ];
    */

    /*
    [ stencilTestState setComparisonFunction:NpComparisonEqual ];
    [ stencilTestState setOperationOnStencilTestFail:NpStencilKeepValue ];
    [ stencilTestState setOperationOnDepthTestFail:NpStencilKeepValue ];
    [ stencilTestState setOperationOnDepthTestPass:NpStencilKeepValue ];
    [ stencilTestState activate ];

    [ cullingState setEnabled:NO ];
    [ cullingState activate ];

    [ skylight render ];
    */

    /*
    [ stencilTestState deactivate ];

    [ t unlock ];

    [[[ NP Graphics ] stateConfiguration ] deactivate ];

    [ gBuffer deactivate ];
    */

    /*
    glBindFramebuffer(GL_READ_FRAMEBUFFER, [ gBuffer glID ]);
    glReadBuffer(GL_COLOR_ATTACHMENT0);
    glBlitFramebuffer(0, 0, 800, 600, 0, 0, 400, 300, GL_COLOR_BUFFER_BIT, GL_LINEAR);
    glReadBuffer(GL_COLOR_ATTACHMENT1);
    glBlitFramebuffer(0, 0, 800, 600, 400, 0, 800, 300, GL_COLOR_BUFFER_BIT, GL_LINEAR);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    glReadBuffer(GL_BACK);
    */

    /*
    //[[ positionsTarget texture ] setColorFormat:NpTextureColorFormatAAA1 ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];
    // bind scene target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ positionsTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ normalsTarget   texture ] texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean       heightfield ] texelUnit:2 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ ocean  supplementalData ] texelUnit:3 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    const FVector2 minMax = [ ocean heightRange ];

    [ heightfieldMinMax setFValue:minMax ];
    [ lightDirection setFValue:[ skylight lightDirection ]];
    [ cameraPosition setValue:[ camera position ]];
    [[ deferredEffect techniqueWithName:@"water_surface" ] activate ];
    //[[ deferredEffect techniqueWithName:@"texture" ] activate ];
    [ fullscreenQuad render ];
    */
}

    //[[ positionsTarget texture ] setColorFormat:NpTextureColorFormatRGBA ];

    /*
    // clear back buffer and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // bind FBO
    [ rtc bindFBO ];

    // attach scene target texture
    [ sceneTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    // attach depth buffer
    [ depthBuffer
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    // set drawbuffers and viewport
    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    // check for completeness
    NSError * fboError = nil;
    if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }

    // render scene
    [ self renderScene ];

    // detach depth buffer and scene texture
    [ depthBuffer detach:NO ];
    [ sceneTarget detach:NO ];

    // attach luminance target
    [ luminanceTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    // check for completeness
    if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // bind scene target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ sceneTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    // compute luminance from scene texture
    [[ fullscreenEffect techniqueWithName:@"luminance" ] activate ];
    [ fullscreenQuad render ];

    // detach luminance target
    [ luminanceTarget detach:NO ];

    // deactivate fbo, reset drawbuffers and viewport
    [ rtc deactivate ];

    // Generate mipmaps for luminance texture, since we want only the highest mipmaplevel
    // as an approximation to the average luminance of the scene
    Half averageLuminance = 0;
    const int32_t  numberOfLevels
        = 1 + (int32_t)floor(logb(MAX(currentResolution.x, currentResolution.y)));

    [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ luminanceTarget texture ]];

    glGenerateMipmap(GL_TEXTURE_2D);
    glGetTexImage(GL_TEXTURE_2D, numberOfLevels - 1, GL_RED, GL_HALF_FLOAT, &averageLuminance);

    [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

    lastFrameLuminance = currentFrameLuminance;
    const float currentFrameAverageLuminance = exp(half_to_float(averageLuminance));
    const float frameTime = [[[ NP Core ] timer ] frameTime ];

    currentFrameLuminance = lastFrameLuminance + (currentFrameAverageLuminance - lastFrameLuminance)
         * (1.0 - pow(0.9, adaptationTimeScale * frameTime));

    //NSLog(@"%f %f", currentFrameAverageLuminance, currentFrameLuminance);

    // bind scene target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ sceneTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    // set tonemapping paramters
    FVector3 toneMappingParameterVector = {currentFrameLuminance, referenceWhite, key};
    [ toneMappingParameters setValue:toneMappingParameterVector ];

    // render tonemapped scene to screen
    [[ fullscreenEffect techniqueWithName:@"tonemap_reinhard" ] activate ];
    [ fullscreenQuad render ];
    */

@end
