#import "NPEngineGraphics.h"
#import "NP.h"

static NPEngineGraphics * NP_ENGINE_GRAPHICS = nil;

@implementation NPEngineGraphics

+ (NPEngineGraphics *)instance
{
    @synchronized(self)
    {
        if ( NP_ENGINE_GRAPHICS == nil )
        {
            [[ self alloc ] init ];
        }
    }

    return NP_ENGINE_GRAPHICS;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (NP_ENGINE_GRAPHICS == nil)
        {
            NP_ENGINE_GRAPHICS = [ super allocWithZone:zone ];
            return NP_ENGINE_GRAPHICS;
        }
    }

    return nil;
}

- (id) init
{
    return [ self initWithName:@"NPEngine Graphics" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    self = [ super init ];

    name = [ newName retain ];
    objectID = crc32_of_pointer(self);

    renderContextManager = [[ NPOpenGLRenderContextManager alloc ] initWithName:@"NPEngine RenderContext Manager" parent:self ];

    stateConfiguration = [[ NPStateConfiguration alloc ] initWithName:@"NPEngine GPU States"       parent:self ];
    stateSetManager    = [[ NPStateSetManager    alloc ] initWithName:@"NPEngine StateSet Manager" parent:self ];

    textureBindingState = [[ NPTextureBindingState alloc ] initWithName:@"NPEngine Texture Binding State" parent:self ];

    vertexBufferManager = [[ NPVertexBufferManager alloc ] initWithName:@"NPEngine VertexBuffer Manager" parent:self ];
    imageManager        = [[ NPImageManager        alloc ] initWithName:@"NPEngine Image Manager"        parent:self ];
    textureManager      = [[ NPTextureManager      alloc ] initWithName:@"NPEngine Texture Manager"      parent:self ];
    effectManager       = [[ NPEffectManager       alloc ] initWithName:@"NPEngine Effect Manager"       parent:self ];
    modelManager        = [[ NPModelManager        alloc ] initWithName:@"NPEngine Model Manager"        parent:self ];
    fontManager         = [[ NPFontManager         alloc ] initWithName:@"NPEngine Font Manager"         parent:self ];

    renderTargetManager = [[ NPRenderTargetManager alloc ] initWithName:@"NPEngine Rendertarget Manager" parent:self ];
    pixelBufferManager  = [[ NPPixelBufferManager  alloc ] initWithName:@"NPEngine Pixelbuffer Manager"  parent:self ];
    r2vbManager         = [[ NPR2VBManager         alloc ] initWithName:@"NPEngine R2VB Manager"         parent:self ];

    viewportManager = [[ NPViewportManager alloc ] initWithName:@"NPEngine Viewport Manager" parent:self ];
    //cameraManager   = [[ NPCameraManager   alloc ] initWithName:@"NPEngine Camera Manager"   parent:self ];

    orthographicRendering = [[ NPOrthographicRendering alloc ] initWithName:@"NPEngine Ortho" parent:self ];

    ready = NO;

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"NP Engine Graphics Dealloc");

    [ orthographicRendering release ];
    //[ cameraManager release ];
    [ viewportManager release ];
    [ r2vbManager release ];
    [ pixelBufferManager release ];
    [ renderTargetManager release ];
    [ fontManager release ];
    [ modelManager release ];
    [ effectManager release ];
    [ textureManager release ];
    [ imageManager release ];
    [ vertexBufferManager release ];
    [ textureBindingState release ];
    [ stateSetManager release ];
    [ stateConfiguration release ];

    [ renderContextManager release ];
    [ name release ];

    [ super dealloc ];
}

- (void) setupWithViewportSize:(IVector2)viewportSize
{   
    NPLOG(@"");
    NPLOG(@"NPEngine Graphics setup....");
    NPLOG(@"Checking for Rendercontext...");

    UInt rcCount = [[ renderContextManager renderContexts ] count ];
    if ( rcCount == 0 )
    {
        NPLOG_ERROR(@"No RenderContext found, bailing out");
        return;
    }
    else
    {
        NPLOG(@"Rendercontext available");
    }

    [[ viewportManager currentViewport ] setControlSize :&viewportSize ];
    [[ viewportManager currentViewport ] setViewportSize:&viewportSize ];

//    [ textureBindingStateManager setup ];

    [ vertexBufferManager setup ];
    [ imageManager   setup ];
    [ textureManager setup ];
    [ effectManager  setup ];

    [ renderTargetManager setup ];

//    [ cameraManager setup ];

    [ stateConfiguration activate ];

    ready = YES;

    NPLOG(@"NPEngine Graphics ready");
    NPLOG(@"");
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    if ( name != newName )
    {
        [ name release ];
        name = [ newName retain ];
    }
}

- (id <NPPObject>) parent
{
    return nil;
}

- (void) setParent:(id <NPPObject>)newParent
{
}

- (UInt32) objectID
{
    return objectID;
}

- (BOOL) ready
{
    return ready;
}

- (NPOpenGLRenderContextManager *) renderContextManager
{
    return renderContextManager;
}

- (NPStateConfiguration *) stateConfiguration
{
    return stateConfiguration;
}

- (NPStateSetManager *) stateSetManager
{
    return stateSetManager;
}

- (NPTextureBindingState *) textureBindingState
{
    return textureBindingState;
}

- (NPVertexBufferManager *) vertexBufferManager
{
    return vertexBufferManager;
}

- (NPImageManager *) imageManager
{
    return imageManager;
}

- (NPTextureManager *) textureManager
{
    return textureManager;
}

- (NPEffectManager *) effectManager
{
    return effectManager;
}

- (NPModelManager *) modelManager
{
    return modelManager;
}

- (NPFontManager *) fontManager
{
    return fontManager;
}

- (NPRenderTargetManager *) renderTargetManager
{
    return renderTargetManager;
}

- (NPPixelBufferManager *) pixelBufferManager
{
    return pixelBufferManager;
}

- (NPR2VBManager *) r2vbManager
{
    return r2vbManager;
}

- (NPViewportManager *) viewportManager
{
    return viewportManager;
}

/*- (NPCameraManager *) cameraManager
{
    return cameraManager;
}*/

- (NPOrthographicRendering *) orthographicRendering
{
    return orthographicRendering;
}

- (void) render
{
    //[ viewportManager render ];
}

- (void) clearFrameBuffer:(BOOL)clearFrameBuffer
              depthBuffer:(BOOL)clearDepthBuffer
            stencilBuffer:(BOOL)clearStencilBuffer
{
    GLbitfield buffersToClear = 0;

    if ( clearFrameBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_COLOR_BUFFER_BIT;
    }

    if ( clearDepthBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_DEPTH_BUFFER_BIT;
    }

    if ( clearStencilBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_STENCIL_BUFFER_BIT;
    }

    glClear(buffersToClear);
}

- (void) swapBuffers
{
    [[ renderContextManager currentRenderContext ] swap ];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
} 

- (void)release
{
    //do nothing
} 

- (id)autorelease
{
    return self;
}

@end

