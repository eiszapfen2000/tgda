#import "Core/Basics/NpBasics.h"
#import "Core/NPObject/NPPObject.h"

@interface NPEngineGraphics : NSObject < NPPObject >
{
    uint32_t objectID;
}

+ (NPEngineGraphics *) instance;

- (id) init;
- (void) dealloc;

- (BOOL) startup;
- (void) shutdown;

- (BOOL) checkForGLError:(NSError **)error;
- (void) checkForGLErrors;

- (void) update;
- (void) render;

@end

