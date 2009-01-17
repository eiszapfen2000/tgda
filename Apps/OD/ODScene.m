#import "NP.h"
#import "ODScene.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODSurface.h"
#import "ODApplicationController.h"
#import "ODEntityManager.h"
#import "ODSceneManager.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self =  [ super initWithName:newName parent:newParent ];

    entities = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ entities removeAllObjects ];

    [ projector release ];
    [ camera    release ];
    [ skybox    release ];
    [ entities  release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName        = [ config objectForKey:@"Name"     ];
    NSArray  * entityFiles      = [ config objectForKey:@"Entities" ];
    NSString * skyboxEntityFile = [ config objectForKey:@"Skybox"   ];

    if ( sceneName == nil || entityFiles == nil || skyboxEntityFile == nil )
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"Scene file %@ is incomplete",path]));
        return NO;
    }

    [ self setName:sceneName ];

    skybox = [[[(ODApplicationController *)[ NSApp delegate ] entityManager ] loadEntityFromPath:skyboxEntityFile ] retain ];

    NSEnumerator * entityFilesEnumerator = [ entityFiles objectEnumerator ];
    id entityFile;
    id entity;

    while (( entityFile = [ entityFilesEnumerator nextObject ] ))
    {
        entity = [[(ODApplicationController *)[ NSApp delegate ] entityManager ] loadEntityFromPath:entityFile ];
        [ entities addObject:entity ];
    }

    return YES;
}

- (void) activate
{
    [ (ODSceneManager *)parent setCurrentScene:self ];
    rtconfig = [ (ODSceneManager *)parent renderTargetConfiguration ];
    pbo = [ (ODSceneManager *)parent pbo ];
    tex = [[[ NP Graphics ] pixelBufferManager ] createTextureCompatibleWithPBO:pbo ];

    camera    = [[ ODCamera    alloc ] initWithName:@"RenderingCamera" parent:self ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector"       parent:self ];

    FVector3 pos = { 0.0f, 2.0f, 5.0f };

    [ camera setPosition:&pos ];

    pos.y = 3.0f;
    pos.z = 0.0f;

    //[ projector setPosition:&pos ];
    [ projector cameraRotateUsingYaw:0.0f andPitch:-30.0f ];
    [ projector setRenderFrustum:NO ];

    /*NSPoint p = { 1024.0f/2.0f, 768.0f/2.0f };
    [[[ NP Input ] mouse ] setPosition:p ];*/
}

- (void) deactivate
{
    [ (ODSceneManager *)parent setCurrentScene:nil ];
    rtconfig = nil;
}

- (id) camera
{
    return camera;
}

- (id) projector
{
    return projector;
}

- (void) update
{
    [[ NP Core  ] update ];
    [[ NP Input ] update ];

    [ camera    update ];
    [ projector update ];
    //[ skybox setPosition:[camera position] ];

    /*NSPoint p = { 1024.0f/2.0f, 768.0f/2.0f };
    [[[ NP Input ] mouse ] setPosition:p ];*/
}

- (void) render
{
    // clear framebuffer/depthbuffer
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // set viewport
    [[ NP Graphics ] render ];

    // activate FBO
    [ rtconfig activate ];
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

    // set FBO viewport
    [[ NP Graphics ] render ];

    [ camera    render ];
    [ skybox    render ];
    //[ projector render ];

    [[[ NP Graphics ] pixelBufferManager ] copyRenderTexture:[rtconfig renderTextureAtIndex:0 ] toPBO:pbo ];

    [ rtconfig deactivate ];

    [[ NP Graphics ] render ];

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glBindTexture(GL_TEXTURE_2D,[[rtconfig renderTextureAtIndex:0 ] renderTextureID ]);

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,0.0f);
        glVertex2f(-1.0f,-1.0f);
        glTexCoord2f(1.0f,0.0f);
        glVertex2f(1.0f,-1.0f);
        glTexCoord2f(1.0f,1.0f);
        glVertex2f(1.0f,0.0f);
        glTexCoord2f(0.0f,1.0f);
        glVertex2f(-1.0f,0.0f);
    glEnd();

    glBindTexture(GL_TEXTURE_2D,0);

    //[[[ NP Graphics ] pixelBufferManager ] copyRenderTexture:[rtconfig renderTextureAtIndex:0 ] toPBO:pbo ];
    [[[ NP Graphics ] pixelBufferManager ] copyPBO:pbo toTexture:tex ];

    glBindTexture(GL_TEXTURE_2D,[tex textureID ]);

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f,0.0f);
        glVertex2f(-1.0f,0.0f);
        glTexCoord2f(1.0f,0.0f);
        glVertex2f(1.0f,0.0f);
        glTexCoord2f(1.0f,1.0f);
        glVertex2f(1.0f,1.0f);
        glTexCoord2f(0.0f,1.0f);
        glVertex2f(-1.0f,1.0f);
    glEnd();

    glBindTexture(GL_TEXTURE_2D,0);

    GLenum error;
    error = glGetError();
    while ( error != GL_NO_ERROR )
    //if ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"main render %s",gluErrorString(error)]));
        error = glGetError();
    }

    [[ NP Graphics ] swapBuffers ];
}

@end
