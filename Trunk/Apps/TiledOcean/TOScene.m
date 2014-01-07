#import "TOScene.h"

#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/Model/NPSUXModelGroup.h"
#import "Graphics/Model/NPSUXModelLod.h"
#import "Graphics/Model/NPSUXModel.h"
#import "Graphics/Model/NPModelManager.h"

#import "Graphics/Camera/NPCamera.h"
#import "Graphics/Camera/NPCameraManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Core/NPEngineCore.h"

#import "Core/NPEngineCore.h"

@implementation TOScene

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOScene" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    camera = nil;
    surface = nil;
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ camera release ];
    [ surfaceVBO release ];
    [ surfaceGroup release ];
    [ surfaceLod release ];
    [ surface release ];
    [ triangleVBO release ];
    [ testCamera release ];

    NSLog(@"scene dealloc%d",[testCamera retainCount]);

    [ super dealloc ];
}

- (TOCamera *) camera
{
    return camera;
}

- (NPSUXModel *) surface
{
    return surface;
}

- (NPSUXModelLod *) surfaceLod
{
    return surfaceLod;
}

- (NPSUXModelGroup *) surfaceGroup
{
    return surfaceGroup;
}

- (NPVertexBuffer *) surfaceVBO
{
    return surfaceVBO;
}

- (void) setup
{
    NSLog(@"scene setup");
    surface = [[ NPSUXModel alloc ] initWithParent:self ];
    surfaceLod = [[ NPSUXModelLod alloc ] initWithParent:surface ];
    surfaceGroup = [[ NPSUXModelGroup alloc ] initWithParent:surfaceLod ];
    surfaceVBO = [[ NPVertexBuffer alloc ] initWithParent:surfaceLod ];

    [ surfaceLod setVertexBuffer:surfaceVBO ];
    [ surfaceLod addGroup:surfaceGroup ];
    [ surface addLod:surfaceLod ];


    triangleVBO = [[ NPVertexBuffer alloc ] init ];

    Float brak[] = {-0.5f,0.0f,0.0f,0.5f,0.0f,0.0f,0.0f,0.5f,0.0f};
    Int brak2[] = {0,1,2};

    [ triangleVBO setPositions:brak ];
    [ triangleVBO setIndices:brak2 ];
    [ triangleVBO setIndexed:YES ];
    [ triangleVBO setMaxVertex:2 ];
    [ triangleVBO setMaxIndex:2 ];
    [ triangleVBO setPrimitiveType:NP_VBO_PRIMITIVES_TRIANGLES ];
    [ triangleVBO setReady:YES ];

    [ triangleVBO uploadVBOWithUsageHint:NP_VBO_UPLOAD_ONCE_RENDER_OFTEN ];

    testCamera = [[[[ NPEngineCore instance ] modelManager ] loadModelFromPath:@"camera.model" ] retain ];
    [ testCamera uploadToGL ];

    //NPSUXModel * ocean = [[[[ NPEngineCore instance ] modelManager ] loadModelFromAbsolutePath:@"/home/icicle/ocean.model" ] retain ];

    if ( testCamera == nil )
    {
        NSLog(@"holy shit");
    }

    //camera = [[[ NPEngineCore instance ] cameraManager ] currentActiveCamera ];
    camera = [[ TOCamera alloc ] init ];

    FVector3 pos;
    FV_X(pos) = 0.0f;
    FV_Y(pos) = 0.0f;
    FV_Z(pos) = 5.0f;

    [ camera setPosition:&pos ];

    //[ camera rotateX:20.0f ];

}

- (void) update
{
    [ camera update ];
}

- (void) render
{
    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    /*glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0,1.0,0.1,50.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();*/

    [ camera render ];
    //gluLookAt(0.0f,0.0f,12.0f,0.0f,0.0f,0.0f,0.0f,1.0f,0.0f);

    /*glBegin(GL_TRIANGLES);
        glColor3f(1.0f,0.0f,0.0f);
        glVertex3f(-0.5f,0.0f,0.0f);
        glVertex3f(0.5f,0.0f,0.0f);
        glVertex3f(0.0f,0.5f,0.0f);
    glEnd();*/

    if ( [ triangleVBO ready ] == YES )
    {
        //NSLog(@"brak");
        [ triangleVBO render ];
    }

    if ( [ surfaceVBO ready ] == YES )
    {
        //NSLog(@"brak");
        [ surfaceVBO render ];
    }

    [ testCamera render ];

    //[ renderContext swap ];
}

@end
