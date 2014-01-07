#import "NP.h"
#import "FCore.h"

@implementation NP ( Fraktale )

+ (FApplicationController *) applicationController
{
    return (FApplicationController *)[ NSApp delegate ];
}

+ (FWindowController *) attributesWindowController
{
    return (FWindowController *)[(FApplicationController *)[ NSApp delegate ] attributesWindowController ];
}

@end
