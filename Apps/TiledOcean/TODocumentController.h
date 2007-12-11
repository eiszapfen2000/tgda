#import <AppKit/AppKit.h>

#import "Core/NPEngineCore.h"

@interface TODocumentController : NSDocumentController
{
    NPEngineCore * core;
}

- (id) init;

@end
