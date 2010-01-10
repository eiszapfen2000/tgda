#import <AL/al.h>
#import <AL/alc.h>
#import <Foundation/NSArray.h>
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface NPSoundChannels : NPObject
{
    NSMutableArray * channels;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) pauseAllChannels;
- (void) stopAllChannels;
- (void) resumeAllChannels;
- (void) update;

@end
