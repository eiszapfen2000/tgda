#import "TODocumentController.h"

//static TODocumentController * sharedController = nil;

@implementation TODocumentController

/*+ (id) sharedDocumentController
{
    if (sharedController == nil)
    {
        sharedController = [[self alloc] init];
    }

    return sharedController;
}*/

- (id) init
{
    self = [ super init ];

    core = [ NPEngineCore instance ];

    NPLOG(@"coooooorrrrrr");

    return self;
}

@end
