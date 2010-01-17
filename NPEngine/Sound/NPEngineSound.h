#import "AL/al.h"
#import "AL/alc.h"
#import "AL/alext.h"
#import "Core/NPObject/NPObject.h"

@interface NPEngineSound : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    ALCdevice * device;
    ALCcontext * context;
}

+ (NPEngineSound *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (NSString *) name;
- (void) setName:(NSString *)newName;
- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;
- (UInt32) objectID;

- (void) checkForALErrors;
- (void) update;

@end
