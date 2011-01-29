#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"

@class NSMutableArray;

@interface NPEffect : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;
    NSMutableArray * techniques;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

@end
