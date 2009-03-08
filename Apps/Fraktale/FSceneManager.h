#import "Core/NPObject/NPObject.h"

@interface FSceneManager : NPObject
{
    id scenes;
    id currentScene;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) loadSceneFromPath:(NSString *)path;
- (id) loadSceneFromAbsolutePath:(NSString *)path;

- (id) currentScene;
- (void) setCurrentScene:(id)newCurrentScene;

- (void) update:(Float)frameTime;
- (void) render;

@end
