#import "Core/NPObject/NPObject.h"
#import "NPKeyboard.h"
#import "NPMouse.h"
#import "NPInputAction.h"
#import "NPInputActions.h"

@class NSEvent;

@interface NPEngineInput : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NPKeyboard * keyboard;
    NPMouse * mouse;
    NPInputActions * inputActions;
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
- (id) keyboard;
- (id) mouse;

- (void) processEvent:(NSEvent *)event;

- (void) update;

@end
