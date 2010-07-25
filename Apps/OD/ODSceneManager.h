#import "Core/NPObject/NPObject.h"

@class ODScene;

@interface ODSceneManager : NPObject
{
    NSMutableDictionary * scenes;
    ODScene * currentScene;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) loadSceneFromPath:(NSString *)path;
- (id) loadSceneFromAbsolutePath:(NSString *)path;

- (ODScene *) currentScene;
- (void) setCurrentScene:(ODScene *)newCurrentScene;

- (void) update:(Float)frameTime;
- (void) render;

@end
