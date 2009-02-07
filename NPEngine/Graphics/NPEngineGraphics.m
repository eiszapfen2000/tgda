#import "NPEngineGraphics.h"
#import "NP.h"

static NPEngineGraphics * NP_ENGINE_GRAPHICS = nil;

@implementation NPEngineGraphics

+ (NPEngineGraphics *)instance
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if ( NP_ENGINE_GRAPHICS == nil )
        {
            [[ self alloc ] init ]; // assignment not done here
        }

        [ lock unlock ];
    }

    [ lock release ];

    return NP_ENGINE_GRAPHICS;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if (NP_ENGINE_GRAPHICS == nil)
        {
            NP_ENGINE_GRAPHICS = [ super allocWithZone:zone ];

            [ lock unlock ];
            [ lock release ];

            return NP_ENGINE_GRAPHICS;  // assignment and return on first allocation
        }
    }

    [ lock release ];

    return nil; //on subsequent allocation attempts return nil
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

    textureBindingStateManager = [[ NPTextureBindingStateManager alloc ] initWithName:@"NPEngine Texture Binding Manager" parent:self ];

    vertexBufferManager = [[ NPVertexBufferManager alloc ] initWithName:@"NPEngine VertexBuffer Manager" parent:self ];
    imageManager        = [[ NPImageManager        alloc ] initWithName:@"NPEngine Image Manager"        parent:self ];
    textureManager      = [[ NPTextureManager      alloc ] initWithName:@"NPEngine Texture Manager"      parent:self ];
    effectManager       = [[ NPEffectManager       alloc ] initWithName:@"NPEngine Effect Manager"       parent:self ];
    modelManager        = [[ NPModelManager        alloc ] initWithName:@"NPEngine Model Manager"        parent:self ];

    renderTargetManager = [[ NPRenderTargetManager alloc ] initWithName:@"NPEngine Rendertarget Manager" parent:self ];
    pixelBufferManager  = [[ NPPixelBufferManager  alloc ] initWithName:@"NPEngine Pixelbuffer Manager"  parent:self ];
    r2vbManager         = [[ NPR2VBManager         alloc ] initWithName:@"NPEngine R2VB Manager"         parent:self ];

    viewportManager = [[ NPViewportManager alloc ] initWithName:@"NPEngine Viewport Manager" parent:self ];
    cameraManager   = [[ NPCameraManager   alloc ] initWithName:@"NPEngine Camera Manager"   parent:self ];

    ready = NO;

    return self;
}

- (void) dealloc
{
    NPLOG(@"");
    NPLOG(@"NP Engine Graphics Dealloc");

    [ cameraManager release ];
    [ viewportManager release ];
    [ r2vbManager release ];
    [ pixelBufferManager release ];
    [ renderTargetManager release ];
    [ modelManager release ];
    [ effectManager release ];
    [ textureManager release ];
    [ imageManager release ];
    [ vertexBufferManager release ];
    [ textureBindingStateManager release ];
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

    [[ viewportManager nativeViewport  ] setViewportSize:viewportSize ];
    [[ viewportManager currentViewport ] setViewportSize:viewportSize ];

    [ textureBindingStateManager setup ];

    [ vertexBufferManager setup ];
    [ imageManager   setup ];
    [ textureManager setup ];
    [ effectManager  setup ];

    [ renderTargetManager setup ];

    [ cameraManager setup ];

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

- (NPTextureBindingStateManager *) textureBindingStateManager
{
    return textureBindingStateManager;
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

- (NPCameraManager *) cameraManager
{
    return cameraManager;
}

- (void) render
{
    [ viewportManager render ];
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

- (unsigned)retainCount
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

