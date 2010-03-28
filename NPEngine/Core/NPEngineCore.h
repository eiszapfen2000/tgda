#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPObjectManager.h"
#import "Core/File/NpFile.h"
#import "Core/Log/NPLogger.h"
#import "Core/RandomNumbers/NPRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPRandomNumberGeneratorManager.h"
#import "Core/Resource/NPResource.h"
#import "Core/Timer/NPTimer.h"
#import "Core/Utilities/NSString+NPEngine.h"
#import "Core/World/NPTransformationState.h"

@interface NPEngineCore : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NPLogger * logger;
    NPTimer * timer;
    NPObjectManager * objectManager;
    NPPathManager * pathManager;
    NPRandomNumberGeneratorManager * randomNumberGeneratorManager;
    NPTransformationState * transformationState;
}

+ (NPEngineCore *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;
- (UInt32) objectID;

- (NPLogger *) logger;
- (NPTimer *) timer;
- (NPObjectManager *) objectManager;
- (NPPathManager *) pathManager;
- (NPRandomNumberGeneratorManager *) randomNumberGeneratorManager;
- (NPTransformationState *) transformationState;

- (void) update;

@end

