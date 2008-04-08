#import <AppKit/AppKit.h>

#import "TODocument.h"
#import "TORNGWindowController.h"
#import "TOOGLWindowController.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"
#import "Core/NPEngineCore.h"


@implementation TODocument

- (id) init
{
    self = [ super init ];

    [ [ NSNotificationCenter defaultCenter ] addObserver:self
                                                selector:@selector(loadModel:)
                                                    name:@"TODocumentCanLoadResources"
                                                  object:nil];

    modelLoaded = NO;
    model = nil;
    glWindowController = nil;
    rngWindowController = nil;

    return self;
}

- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type
{
    return NO;
}

- (NSData*) dataRepresentationOfType:(NSString*)type
{
    return nil;
}

- (void) makeWindowControllers
{
    glWindowController = [[ TOOGLWindowController alloc ] init ];
    rngWindowController = [[ TORNGWindowController alloc ] init ];

	[ self addWindowController:glWindowController ];
	[ self addWindowController:rngWindowController];
}

- (id) glWindowController
{
    return glWindowController;
}

- (id) rngWindowController
{
    return rngWindowController;
}

- (void) loadModel:(NSNotification *)aNot
{

}

- (void) loadModel
{
    NSLog(@"loadmodel");
    if ( modelLoaded == NO )
    {
        model = [[[[ NPEngineCore instance ] modelManager ] loadModelFromPath:@"camera.model" ] retain ];
        modelLoaded = YES;
    }    
}

@end
