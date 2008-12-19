#import "ODApplicationController.h"
#import "ODSceneManager.h"
#import "ODEntityManager.h"
#import "NP.h"

@implementation ODApplicationController

- (void) configureResourcePaths
{
    NSString * path = [[ NSBundle mainBundle ] bundlePath];
    NSString * contentPath = [path stringByAppendingPathComponent:@"Resources/Content" ];
    NSString * modelPath  = [contentPath stringByAppendingPathComponent:@"Models" ];
    NSString * entitiesPath  = [contentPath stringByAppendingPathComponent:@"Entities" ];
    NSString * scenesPath = [contentPath stringByAppendingPathComponent:@"Scenes"];
    NSString * effectPath = [contentPath stringByAppendingPathComponent:@"Effects"];
    NSString * statesetPath = [contentPath stringByAppendingPathComponent:@"Statesets"];

    [[[ NP Core ] pathManager ] addLookUpPath:modelPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:entitiesPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:scenesPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:effectPath ];
    [[[ NP Core ] pathManager ] addLookUpPath:statesetPath ];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [ super createRenderWindow ];

    [ self configureResourcePaths ];

    entityManager = [[ ODEntityManager alloc ] init ];
    sceneManager  = [[ ODSceneManager  alloc ] init ];
    id dummyscene = [ sceneManager loadSceneFromPath:@"skybox.scene" ];
    NSLog(@"%@",[dummyscene description]);

    t0 = [ NSDate timeIntervalSinceReferenceDate ];
    t = dt = 0.0;
    frames = 0;

    // Load initial resources here
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{

    // Delete resources here....

    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
    // .... or here

    [ entityManager release ];
    [ sceneManager  release ];

    [ NSApp setDelegate:nil ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (id) entityManager
{
    return entityManager;
}

- (id) sceneManager
{
    return sceneManager;
}

- (void) update
{
    [[ NP Core  ] update ];
    [[ NP Input ] update ];
}

- (void) render
{
    [[ NP Graphics ] render ];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();  

    glColor3f(1.0f,0.0f,0.0f);
    glBegin(GL_TRIANGLES);
    glVertex2f(-0.5f,0.0f);
    glVertex2f(0.5f,0.0f);
    glVertex2f(0.0f,0.5f);
    glEnd();

    frames++;

    double t_new = [ NSDate timeIntervalSinceReferenceDate ];
    dt = t_new - t;
    t = t_new;

    if ( t - t0 >= 5.0 )
    {
        double seconds = t - t0;
        double fps = frames / seconds;
        printf("%d frames in %6.3f seconds = %6.3f FPS\n", frames, seconds, fps);
        t0 = t;
        frames = 0;
    }

    GLenum error;
    error = glGetError();

    if ( error != GL_NO_ERROR )
    {
        NPLOG_ERROR(([NSString stringWithFormat:@"%s",gluErrorString(error)]));
    }

    [[ NP Graphics ] swapBuffers ];
}

@end
