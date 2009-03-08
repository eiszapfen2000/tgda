#import "NP.h"
#import "FCore.h"

@implementation NP ( Fraktale )

+ (FApplicationController *) applicationController
{
    return (FApplicationController *)[ NSApp delegate ];
}

@end
