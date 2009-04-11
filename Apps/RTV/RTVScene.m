#import "NP.h"
#import "RTVCore.h"
#import "RTVScene.h"
#import "RTVSceneManager.h"

@implementation FScene

- (id) init
{
    return [ self initWithName:@"Scene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    return YES;
}

- (void) activate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:self ];
}

- (void) deactivate
{
    [[[ NP applicationController ] sceneManager ] setCurrentScene:nil ];
}

- (void) update:(Float)frameTime
{
}

- (void) render
{
    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];
}

@end
