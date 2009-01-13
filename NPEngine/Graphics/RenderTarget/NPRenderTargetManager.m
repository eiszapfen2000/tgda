#import "NPRenderTargetManager.h"

#import "NP.h"

@implementation NPRenderTargetManager

- (id) init
{
    return [ self initWithName:@"NPRenderTargetConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    colorBufferCount = 0;
    maxRenderBufferSize = 0;
    renderTargetConfigurations = [[ NSMutableArray alloc ] init ];
    currentRenderTargetConfiguration = nil;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentRenderTargetConfiguration);
    [ renderTargetConfigurations removeAllObjects ];
    [ renderTargetConfigurations release ];

    [ super dealloc ];
}

- (void) setup
{
    if ( [[[[ NP Graphics ] renderContextManager ] currentRenderContext ] isExtensionSupported:@"GL_ARB_draw_buffers" ] == YES )
    {
        glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS_EXT, &colorBufferCount);
    }

    if ( [[[[ NP Graphics ] renderContextManager ] currentRenderContext ] isExtensionSupported:@"GL_EXT_framebuffer_object" ] == YES )
    {
        glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE_EXT, &maxRenderBufferSize);
    }

    NPLOG(([NSString stringWithFormat:@"Maximum supported color buffer count: %d",colorBufferCount]));
    NPLOG(([NSString stringWithFormat:@"Maximum supported render buffer size: %d",maxRenderBufferSize]));
}

- (Int) colorBufferCount
{
    return colorBufferCount;
}

- (id) currentRenderTargetConfiguration
{
    return currentRenderTargetConfiguration;
}

- (void) setCurrentRenderTargetConfiguration:(id)newRenderTargetConfiguration
{
    ASSIGN(currentRenderTargetConfiguration,newRenderTargetConfiguration);
}

@end
