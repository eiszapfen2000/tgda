#import <AppKit/AppKit.h>

#import "TODocument.h"
#import "TORNGWindowController.h"
#import "TOOGLWindowController.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"
#import "Core/NPEngineCore.h"


@implementation TODocument

- (id) init
{
    self = [ super init ];

    /*[[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(loadModel:)
                                                   name:@"TODocumentCanLoadResources"
                                                 object:nil];*/

    glWindowController = nil;
    rngWindowController = nil;

    scene = [[ TOScene alloc ] initWithName:[self displayName] parent:self ];

    return self;
}

- (void) dealloc
{
    [ glWindowController release ];
    [ rngWindowController release ];
    [ scene release ];

    [ super dealloc ];
}

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type
{
    return NO;
}

- (NSData*) dataRepresentationOfType:(NSString*)type
{
    return nil;
}

- (void) setup
{
    if ( [[ NPEngineCore instance ] isReady ] == NO )
    {
        [[ NPEngineCore instance ] setup ];
    }

    [ scene setup ];
}

- (void) makeWindowControllers
{
    rngWindowController = [[ TORNGWindowController alloc ] init ];
    glWindowController = [[ TOOGLWindowController alloc ] init ];

	[ self addWindowController:rngWindowController];
	[ self addWindowController:glWindowController ];
}

- (id) glWindowController
{
    return glWindowController;
}

- (id) rngWindowController
{
    return rngWindowController;
}

- (TOScene *)scene
{
    return scene;
}

@end
