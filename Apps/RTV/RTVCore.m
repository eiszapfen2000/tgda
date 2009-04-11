#import "NP.h"
#import "RTVCore.h"

@implementation NP ( RTV )

+ (RTVApplicationController *) applicationController
{
    return (RTVApplicationController *)[ NSApp delegate ];
}
@end
