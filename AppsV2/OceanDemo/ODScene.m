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

    lastFrameResolution.x = lastFrameResolution.y = INT_MAX;
    currentResolution.x = currentResolution.y = 0;

    referenceWhite = 1.0f;
    key = 0.72f;
    adaptationTimeScale = 30.0f;
    lastFrameLuminance = currentFrameLuminance = 1.0f;

    rtc = [[ NPRenderTargetConfiguration alloc ] init ];
    sceneTarget = [[ NPRenderTexture alloc ] init ];
    luminanceTarget = [[ NPRenderTexture alloc ] init ];
    depthBuffer = [[ NPRenderBuffer alloc ] init ];

    fullscreenEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"fullscreen.effect" ];

    ASSERT_RETAIN(fullscreenEffect);

    toneMappingParameters
        = [ fullscreenEffect variableWithName:@"toneMappingParameters" ];

    NSAssert(toneMappingParameters != nil, @"");

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

    // enable depth write and depth test
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NPEngineGraphics instance ] stateConfiguration ] depthTestState ] activate ];

    // set view and projection
    [ camera render ];

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

    // Clear back buffer and depth buffer
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
    [[ luminanceTarget texture ] generateMipMaps ];

    [[[ NP Graphics ] textureBindingState ] clear ];

    // read back of highest mipmap level
    const uint32_t luminanceTargetWidth  = [ luminanceTarget width  ];
    const uint32_t luminanceTargetHeight = [ luminanceTarget height ];
    const int32_t  numberOfLevels = 1 + (int32_t)floor(logb(MAX(luminanceTargetWidth, luminanceTargetHeight)));
    Half averageLuminance = 0;
    glBindTexture(GL_TEXTURE_2D, [[ luminanceTarget texture ] glID ]);
    glGetTexImage(GL_TEXTURE_2D, numberOfLevels - 1, GL_RED, GL_HALF_FLOAT, &averageLuminance);
    glBindTexture(GL_TEXTURE_2D, 0);

    lastFrameLuminance = currentFrameLuminance;
    const float currentFrameAverageLuminance = exp(half_to_float(averageLuminance));
    const float frameTime = [[[ NP Core ] timer ] frameTime ];

    currentFrameLuminance = lastFrameLuminance + (currentFrameAverageLuminance - lastFrameLuminance)
         * (float)(1.0 - pow(0.9, adaptationTimeScale * frameTime));

    //NSLog(@"%f %f", currentFrameAverageLuminance, currentFrameLuminance);

    // bind scene target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ sceneTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    FVector3 toneMappingParameterVector = {currentFrameLuminance, referenceWhite, key};
    [ toneMappingParameters setValue:toneMappingParameterVector ];
    [[ fullscreenEffect techniqueWithName:@"tonemap_reinhard" ] activate ];
    [ fullscreenQuad render ];

    /*
    // Bind scene and luminance texture, and do tonemapping
    [[ terrainScene texture ] activateAtColorMapIndex:0 ];

    FVector3 toneMappingParameterVector = { (Float)currentFrameLuminance, referenceWhite, key };
    [ fullscreenEffect uploadFVector3Parameter:toneMappingParameters andValue:&toneMappingParameterVector ];
    [ fullscreenEffect activateTechniqueWithName:@"tonemap" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
    */

    /*
    // bind luminance target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ luminanceTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];

    // render luminance texture
    [[ fullscreenEffect techniqueWithName:@"texture_single_channel" ] activate ];
    [ fullscreenQuad render ];
    */
}

@end
