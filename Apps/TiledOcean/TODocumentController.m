#import "TODocumentController.h"

@implementation TODocumentController

- (id) init
{
    self = [ super init ];

    core = [ NPEngineCore instance ];

    [[ NSNotificationCenter defaultCenter ]  addObserver:self
                                                selector:@selector(newContextReady:)
                                                    name:@"TOOpenGLWindowContextReady"
                                                  object:nil ];

    return self;
}

- (void) newContextReady:(NSNotification *)aNot
{
    if ( [ core isReady ] == NO )
    {
        [ core setup ];
    }
}

@end
