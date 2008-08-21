#import "TODocumentController.h"
#import "fftw3.h"

@implementation TODocumentController

- (id) init
{
    self = [ super init ];

    if ( fftw_init_threads() == 0 )
    {
        NPLOG(@"FFTW initialisation failed");
    }

    core = [ NPEngineCore instance ];

    [[ NSNotificationCenter defaultCenter ] addObserver:self
                                               selector:@selector(newContextReady:)
                                                   name:@"TOOpenGLWindowContextReady"
                                                 object:nil ];
    return self;
}

- (void) newContextReady:(NSNotification *)aNot
{
    if ( [ core ready ] == NO )
    {
        [ core setup ];
    }
}

- (void) close:(id)sender
{
    [[ self currentDocument ] close ];
}

@end
