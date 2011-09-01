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
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/NPViewport.h"
#import "NP.h"
#import "Entities/ODPEntity.h"
#import "Entities/ODCamera.h"
#import "Entities/ODProjector.h"
#import "Entities/ODProjectedGrid.h"
#import "Entities/ODPreethamSkylight.h"
#import "Entities/ODEntity.h"
#import "ODScene.h"

@interface ODScene (Private)

- (id <ODPEntity>) loadEntityFromFile:(NSString *)fileName
                                error:(NSError **)error
                                     ;

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

    entities = [[ NSMutableArray alloc ] init ];

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

    // render targets
    rtc = [[ NPRenderTargetConfiguration alloc ] init ];
    sceneTarget = [[ NPRenderTexture alloc ] init ];
    luminanceTarget = [[ NPRenderTexture alloc ] init ];
    depthBuffer = [[ NPRenderBuffer alloc ] init ];

    // effect and effect paramters
    fullscreenEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"fullscreen.effect" ];

    ASSERT_RETAIN(fullscreenEffect);

    toneMappingParameters
        = [ fullscreenEffect variableWithName:@"toneMappingParameters" ];

    NSAssert(toneMappingParameters != nil, @"");

    // fullscreen quad for render target display
    fullscreenQuad = [[ NPFullscreenQuad alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];
    DESTROY(entities);

    SAFE_DESTROY(skylight);
    SAFE_DESTROY(projectedGrid);
    SAFE_DESTROY(projector);
    SAFE_DESTROY(camera);
    SAFE_DESTROY(file);

    DESTROY(depthBuffer);
    DESTROY(luminanceTarget);
    DESTROY(sceneTarget);
    DESTROY(rtc);
    DESTROY(fullscreenQuad);
    DESTROY(fullscreenEffect);

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

    NSString * sceneName               = [ sceneContents objectForKey:@"Name"      ];
    NSString * skylightEntityFile      = [ sceneContents objectForKey:@"Skylight"  ];
    NSString * cameraEntityFile        = [ sceneContents objectForKey:@"Camera"    ];
    NSString * projectorEntityFile     = [ sceneContents objectForKey:@"Projector" ];
    NSArray  * entityFiles             = [ sceneContents objectForKey:@"Entities"  ];
    NSString * projectedGridEntityFile = [ sceneContents objectForKey:@"ProjectedGrid" ];

    [ self setName:sceneName ];

    camera        = [ self loadEntityFromFile:cameraEntityFile        error:NULL ];
    projector     = [ self loadEntityFromFile:projectorEntityFile     error:NULL ];
    projectedGrid = [ self loadEntityFromFile:projectedGridEntityFile error:NULL ];
    skylight      = [ self loadEntityFromFile:skylightEntityFile      error:NULL ];

    ASSERT_RETAIN(camera);
    ASSERT_RETAIN(projector);
    ASSERT_RETAIN(projectedGrid);
    ASSERT_RETAIN(skylight);

    [ projector setCamera:camera ];
    [ projectedGrid setProjector:projector ];
    [ skylight setCamera:camera ];

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

- (ODProjector *) projector
{
    return projector;
}

- (ODProjectedGrid *) projectedGrid
{
    return projectedGrid;
}

- (ODPreethamSkylight *) skylight
{
    return skylight;
}

- (void) update:(const float)frameTime
{
    NPViewport * viewport = [[ NP Graphics] viewport ];
    currentResolution.x = [ viewport width  ];
    currentResolution.y = [ viewport height ];

    if ( [ projector connecting ] == YES )
    {
        [ camera lockInput ];

        startOrientation = [ camera orientation ];
        endOrientation   = [ projector orientation ];

        FVector3 fs = fquat_q_forward_vector(&startOrientation);
        FVector3 fe = fquat_q_forward_vector(&endOrientation);

        double cosAngle = startOrientation.w * endOrientation.w + startOrientation.v.x * endOrientation.v.x + startOrientation.v.y * endOrientation.v.y + startOrientation.v.z * endOrientation.v.z;
        double angle = acos(cosAngle);
        NSLog(@"START ANGLE %f", angle);

        /*
        NSLog(@"START F: %f %f %f", fs.x, fs.y, fs.z);
        NSLog(@"END F: %f %f %f", fe.x, fe.y, fe.z);
        NSLog(@"DOT %f", fv3_vv_dot_product(&fs, &fe));

        NSLog(@"START: %f %f %f %f", startOrientation.v.x, startOrientation.v.y, startOrientation.v.z, startOrientation.w);
        NSLog(@"END: %f %f %f %f", endOrientation.v.x, endOrientation.v.y, endOrientation.v.z, endOrientation.w);
        */

        startPosition = [ camera position ];
        endPosition   = [ projector position ];
        connecting = YES;

        NSLog(@"Connecting");
    }

    if ( [ projector disconnecting ] == YES )
    {
        disconnecting = YES;

        NSLog(@"Disconnecting");
    }

    if ( connecting == YES )
    {
        animationTime += frameTime;
        animationTime = MIN(animationTime, 2.0f);

        FQuaternion slerped;
        fquat_qqs_slerp_q(&startOrientation, &endOrientation, animationTime / 2.0f, &slerped);

        double cosAngle = startOrientation.w * slerped.w + startOrientation.v.x * slerped.v.x + startOrientation.v.y * slerped.v.y + startOrientation.v.z * slerped.v.z;
        double angle = acos(cosAngle);
        NSLog(@"ANGLE %f", angle);

        [ camera setOrientation:slerped ];

        if ( animationTime == 2.0f )
        {
            connecting = NO;
            animationTime = 0.0f;
            NSLog(@"UNLOCK");
            //[ camera unlockInput ];
        }
    }

    [ camera        update:frameTime ];
    [ projector     update:frameTime ];
    [ projectedGrid update:frameTime ];
    [ skylight      update:frameTime ];

    const NSUInteger numberOfEntities = [ entities count ];
    for ( NSUInteger i = 0; i < numberOfEntities; i++ )
    {
        [[ entities objectAtIndex:i ] update:frameTime ];
    }
}

- (void) renderScene
{
    // clear color and depth buffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // set view and projection
    [ camera render ];

    // render skylight
    [ skylight render ];

    // activate culling, depth write and depth test
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NpCullfaceBack ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    // render projected grid
    [ projectedGrid render ];

    // render entities
    [ entities makeObjectsPerformSelector:@selector(render) ];

    // render projector frustum
    [ projector render ];

    // reset states, makes depth buffer writable
    [[[ NP Graphics ] stateConfiguration ] deactivate ];
}

- (void) render
{
    if (( currentResolution.x != lastFrameResolution.x )
        || ( currentResolution.y != lastFrameResolution.y ))
    {
        [ rtc setWidth:currentResolution.x  ];
        [ rtc setHeight:currentResolution.y ];

        [ sceneTarget generate:NpRenderTargetColor
                         width:currentResolution.x
                        height:currentResolution.y
                   pixelFormat:NpImagePixelFormatRGBA
                    dataFormat:NpImageDataFormatFloat16
                 mipmapStorage:YES
                         error:NULL ];

        [ luminanceTarget generate:NpRenderTargetColor
                             width:currentResolution.x
                            height:currentResolution.y
                       pixelFormat:NpImagePixelFormatR
                        dataFormat:NpImageDataFormatFloat16
                     mipmapStorage:YES
                             error:NULL ];

        [ depthBuffer generate:NpRenderTargetDepth
                         width:currentResolution.x
                        height:currentResolution.y
                   pixelFormat:NpImagePixelFormatUnknown
                    dataFormat:NpRenderBufferDataFormatDepth32
                         error:NULL ];

        lastFrameResolution = currentResolution;
    }

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
                                  bindFBO:NO ];

    // set drawbuffers and viewport
    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    /*
    // check for completeness
    NSError * fboError = nil;
    if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }
    */

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

    /*
    // check for completeness
    if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }
    */

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
}

@end
