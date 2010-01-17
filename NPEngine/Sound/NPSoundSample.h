#import <AL/al.h>
#import "Core/NPObject/NPObject.h"

@interface NPSoundSample : NPObject
{
    UInt32 alID;
    Float volume;
    Float range;
    Float length;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (UInt32) alID;
- (Float) volume;
- (Float) range;
- (Float) length;

- (void) clear;

- (BOOL) loadFromPath:(NSString *)path;

@end
