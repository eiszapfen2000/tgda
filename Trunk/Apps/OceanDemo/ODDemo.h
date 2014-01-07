//#import <Foundation/Foundation.h>
#import "Core/NPObject/NPObject.h"

@class ODScene;

@interface ODDemo : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    NSTimer * timer;

    NSMutableDictionary * scenes;
    ODScene * currentScene;
}

+ (ODDemo *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;

- (UInt32) objectID;

- (ODScene *) currentScene;
- (void) setCurrentScene:(ODScene *)newCurrentScene;

- (void) setupRenderLoop;
- (void) update;
- (void) render;
- (void) updateAndRender:(NSTimer *)timer;

@end
