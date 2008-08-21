#import <AppKit/AppKit.h>

#import "TODocument.h"
#import "TOScene.h"
#import "TOOceanSurfaceGenerator.h"
#import "TOFrequencySpectrumGenerator.h"
#import "TOOGLWindowController.h"
#import "TOOceanSurfaceGeneratorSettingsWindowController.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"
#import "Core/NPEngineCore.h"


@implementation TODocument

- (id) init
{
    self = [ super init ];

    [[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(oceanSurfaceGenerationDidStart:)
                                                   name:@"TOOceanSurfaceGenerationDidStart"
                                                 object:oceanSurfaceGenerator];

    [[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(oceanSurfaceGenerationDidEnd:)
                                                   name:@"TOOceanSurfaceGenerationDidEnd"
                                                 object:oceanSurfaceGenerator];

    glWindowController = nil;
    oceanSurfaceGeneratorSettingsWindowController = nil;

    oceanSurfaceGenerator = [[ TOOceanSurfaceGenerator alloc ] initWithName:[self displayName] parent:nil ];

    [ self updateChangeCount:NSChangeDone ];

    return self;
}


/*- (BOOL) loadDataRepresentation:(NSData*)representation ofType:(NSString*)type
{
    return NO;
}

- (NSData *) dataRepresentationOfType:(NSString*) type
{
    return nil;
}*/

- (void) makeWindowControllers
{
    glWindowController = [[ TOOGLWindowController alloc ] init ];
    oceanSurfaceGeneratorSettingsWindowController = [[ TOOceanSurfaceGeneratorSettingsWindowController alloc ] init ];

    [ self addWindowController:oceanSurfaceGeneratorSettingsWindowController ];
	[ self addWindowController:glWindowController ];

    [ glWindowController release ];
    [ oceanSurfaceGeneratorSettingsWindowController release ];

    [ oceanSurfaceGeneratorSettingsWindowController setOceanSurfaceGenerator:oceanSurfaceGenerator ];
}

- (id) glWindowController
{
    return glWindowController;
}

- (id) oceanSurfaceGeneratorSettingsWindowController
{
    return oceanSurfaceGeneratorSettingsWindowController;
}

- (TOOceanSurfaceGenerator *) oceanSurfaceGenerator
{
    return oceanSurfaceGenerator;
}

/*- (TOScene *)scene
{
    return scene;
}*/

- (void) oceanSurfaceGenerationDidEnd:(NSNotification *)aNot;
{
    TOFrequencySpectrumGenerator * fsg = [[ aNot userInfo ] objectForKey:@"FSG" ];

    Float * vertexArray = [ oceanSurfaceGenerator buildVertexArrayUsingFSG:fsg ];
    Int * indexArray = [ oceanSurfaceGenerator buildIndexArrayUsingFSG:fsg ];
    Int maxVertex = [ fsg resX ]*[ fsg resY ] - 1;
    Int maxIndex = ([ fsg resX ]-1) * ([fsg resY]-1) * 6;

    [[ glWindowController openglView ] buildVBOUsingVertexArray:vertexArray
                                                     indexArray:indexArray
                                                      maxVertex:maxVertex
                                                       maxIndex:maxIndex ];
}

- (BOOL)writeToFile: (NSString *)fileName ofType: (NSString *)type
{
    NSLog(@"rudsfisdgfisdgfifao");

    return [[[ NPEngineCore instance ] modelManager ] saveModel:[[[ glWindowController openglView ] scene ] surface ] atAbsolutePath:fileName ];
}

@end
