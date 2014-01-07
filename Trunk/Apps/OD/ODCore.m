#import "NP.h"
#import "ODCore.h"

@implementation NP ( OceanDemo )

+ (ODApplicationController *) applicationController
{
    return (ODApplicationController *)[ NSApp delegate ];
}

@end
