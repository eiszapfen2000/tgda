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

    referenceWhite = 0.85f;
    key = 0.38f;
    adaptationTimeScale = 30.0f;
    luminanceMaxMipMapLevel = -1;
    lastFrameLuminance = currentFrameLuminance = 1.0f;

    rtc = [[ NPRenderTargetConfiguration alloc ] init ];
    sceneTarget = [[ NPRenderTexture alloc ] init ];
    luminanceTarget = [[ NPRenderTexture alloc ] init ];
    depthBuffer = [[ NPRenderBuffer alloc ] init ];

    fullscreenEffect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"fullscreen.effect" ];

    ASSERT_RETAIN(fullscreenEffect);

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
    currentResolution.x = [ viewport width ];
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

/*
    IVector2 * resolution = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    // setup fbo
    [ terrainRTC setWidth:resolution->x ];
    [ terrainRTC setHeight:resolution->y ];
    [ terrainRTC resetColorTargetsArray ];
    [ terrainRTC bindFBO ];

    // setup terrainScene as target
    [[ terrainRTC colorTargets ] replaceObjectAtIndex:0 withObject:terrainScene ];
    [ terrainScene attachToColorBufferIndex:0 ];
    [ depthBuffer attach ];
    [ terrainRTC activateViewport ];
    [ terrainRTC activateDrawBuffers ];
    [ terrainRTC checkFrameBufferCompleteness ];

    // clear terrainScene and depthBuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    [ camera render ];
    [ skylight render ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setCullFace:NP_BACK_FACE ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[ NP Graphics ] stateConfiguration ] activate ];

    [ terrain render ];

    // detach targets    
    [ terrainScene detach ];
    [ depthBuffer detach ];

    // deactivate depth test
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // prepare luminanceTarget
    [[ terrainRTC colorTargets ] replaceObjectAtIndex:0 withObject:luminanceTarget ];
    [ luminanceTarget attachToColorBufferIndex:0 ];
    [ terrainRTC activateViewport ];
    [ terrainRTC activateDrawBuffers ];
    [ terrainRTC checkFrameBufferCompleteness ];

    // compute terrainScene's luminance into luminanceTarget
    [[ terrainScene texture ] activateAtColorMapIndex:0 ];
    [ fullscreenEffect activateTechniqueWithName:@"luminance" ];
    [ fullscreenQuad render ];
    [ luminanceTarget detach ];

    // deactivate render targets
    [ terrainRTC unbindFBO ];
    [ terrainRTC deactivateDrawBuffers ];
    [ terrainRTC deactivateViewport ];

    // Generate mipmaps for luminance texture, since we want only the highest mipmaplevel
    // as an approximation to the average luminance of the scene
    [ luminanceTarget generateMipMaps ];

    Half * averageLuminance;
    Int32 numberOfElements = [[ luminanceTarget texture ] downloadMaxMipmapLevelIntoHalfs:&averageLuminance ];
    NSAssert(averageLuminance != NULL && numberOfElements != 0, @"Failed to read average luminance back to memory.");

    lastFrameLuminance = currentFrameLuminance;
    Float currentFrameAverageLuminance = exp(half_to_float(averageLuminance[0]));
    Double frameTime = [[[ NP Core ] timer ] frameTime ];

    currentFrameLuminance = lastFrameLuminance + (currentFrameAverageLuminance - lastFrameLuminance)
         * (Float)(1.0 - pow(0.9, adaptationTimeScale * frameTime));

    FREE(averageLuminance);

    // Bind scene and luminance texture, and do tonemapping
    [[ terrainScene texture ] activateAtColorMapIndex:0 ];

    FVector3 toneMappingParameterVector = { (Float)currentFrameLuminance, referenceWhite, key };
    [ fullscreenEffect uploadFVector3Parameter:toneMappingParameters andValue:&toneMappingParameterVector ];
    [ fullscreenEffect activateTechniqueWithName:@"tonemap" ];
    [ fullscreenQuad render ];
    [ fullscreenEffect deactivate ];
*/

- (void) render
{
    if (( currentResolution.x != lastFrameResolution.x )
        || ( currentResolution.y != lastFrameResolution.y ))
    {
        NSLog(@"Target resize");

        [ rtc setWidth:currentResolution.x  ];
        [ rtc setHeight:currentResolution.y ];

        [ sceneTarget generate:NpRenderTargetColor
                         width:currentResolution.x
                        height:currentResolution.y
                   pixelFormat:NpImagePixelFormatRGBA
                    dataFormat:NpImageDataFormatFloat16
                         error:NULL ];

        [ luminanceTarget generate:NpRenderTargetColor
                             width:currentResolution.x
                            height:currentResolution.y
                       pixelFormat:NpImagePixelFormatR
                        dataFormat:NpImageDataFormatFloat16
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

    // bind target for scene rendering
    [ rtc bindFBO ];
    [ sceneTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [ depthBuffer
        attachToRenderTargetConfiguration:rtc
                                  bindFBO:NO ];

    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    /*
    NSError * fboError = nil;
    if ([ rtc checkFrameBufferCompleteness:&fboError ] == NO )
    {
        NPLOG_ERROR(fboError);
    }
    */

    [ self renderScene ];

    [ rtc deactivate ];

    // reset matrices
    [[[ NP Core ] transformationState ] reset ];

    // bind scene target as texture source
    [[[ NP Graphics ] textureBindingState ] setTexture:[ sceneTarget texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] activate ];
    
    // render fullscreen quad
    [[ fullscreenEffect techniqueWithName:@"texture" ] activate ];
    [ fullscreenQuad render ];
}

@end
