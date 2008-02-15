#import "TODocumentController.h"

@implementation TODocumentController

- (id) init
{
    self = [ super init ];

    core = [ NPEngineCore instance ];

    [ [ NSNotificationCenter defaultCenter ] addObserver:self
                                                selector:@selector(newContextReady)
                                                    name:@"TOOpenGLWindowContextReady"
                                                  object:nil];

    return self;
}

- (void) newContextReady
{
    if ( [ core isReady ] == NO )
    {
        [ core setup ];
    }
}

@end
