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

    /*[[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(setup:)
                                                   name:@"TODocumentCanLoadResources"
                                                 object:nil];*/

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
    //scene = [[ TOScene alloc ] initWithName:[self displayName] parent:nil ];

    return self;
}

- (void) dealloc
{
    [ oceanSurfaceGeneratorSettingsWindowController release ];
    [ oceanSurfaceGenerator release ];
    //[ scene release ];

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

- (void) setup:(NSNotification *)aNot
{
    //[ scene setup ];
    //[ scene setRenderContext:[[glWindowController openglView] renderContext]];

    /*timer = [ NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                              target:self
                                            selector:@selector(updateAndRender:)
                                            userInfo:nil
                                             repeats:YES ];*/

    //[ self updateChangeCount:NSChangeDone ];
}

/*- (void) updateAndRender:(NSTimer *)theTimer
{
    [ scene update ];
    [ scene render ];
}*/

- (void) makeWindowControllers
{
    glWindowController = [[ TOOGLWindowController alloc ] init ];
    oceanSurfaceGeneratorSettingsWindowController = [[ TOOceanSurfaceGeneratorSettingsWindowController alloc ] init ];

    [ self addWindowController:oceanSurfaceGeneratorSettingsWindowController ];
	[ self addWindowController:glWindowController ];

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
    //NPVertexBuffer * vbo = [ scene surfaceVBO ];
    TOFrequencySpectrumGenerator * fsg = [[ aNot userInfo ] objectForKey:@"FSG" ];

    Float * vertexArray = [ oceanSurfaceGenerator buildVertexArrayUsingFSG:fsg ];
    //[ vbo setPositions:vertexArray ];
    Int * indexArray = [ oceanSurfaceGenerator buildIndexArrayUsingFSG:fsg ];
    //[ vbo setIndices:indexArray ];

    //[ vbo setIndexed:YES ];

    Int maxVertex = [ fsg resX ]*[ fsg resY ] - 1;
    //[ vbo setMaxVertex:maxVertex ];

    Int maxIndex = ([ fsg resX ]-1) * ([fsg resY]-1) * 6;
    //[ vbo setMaxIndex:maxIndex ];

    //[ vbo setPrimitiveType:NP_VBO_PRIMITIVES_TRIANGLES ];
    //[ vbo setReady:YES ];

    //[ vbo uploadVBOWithUsageHint:NP_VBO_UPLOAD_ONCE_RENDER_OFTEN ];

    [[ glWindowController openglView ] buildVBOUsingVertexArray:vertexArray
                                                     indexArray:indexArray
                                                      maxVertex:maxVertex
                                                       maxIndex:maxIndex ];
}

@end
