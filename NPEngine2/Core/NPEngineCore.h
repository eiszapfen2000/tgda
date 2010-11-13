#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPObjectManager.h"
#import "Core/File/NpFile.h"
#import "Core/Timer/NPTimer.h"
#import "Core/Utilities/NSString+NPEngine.h"
#import "Core/World/NPTransformationState.h"

@interface NPEngineCore : NSObject < NPPObject >
{
    uint32_t objectID;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPLocalPathManager * localPathManager;
    NPTransformationState * transformationState;
}

+ (NPEngineCore *) instance;

- (id) init;
- (void) dealloc;

- (NPTimer *) timer;
- (NPObjectManager *) objectManager;
- (NPLocalPathManager *) localPathManager;
- (NPTransformationState *) transformationState;

- (void) update;

@end

