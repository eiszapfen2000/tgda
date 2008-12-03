#import "Core/NPObject/NPObject.h"
#import "NPKeyboard.h"
#import "NPMouse.h"

@class NSEvent;

@interface NPEngineInput : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NPKeyboard * keyboard;
    NPMouse * mouse;
}

+ (NPEngineInput *) instance;

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

- (void) processEvent:(NSEvent *)event;

@end
