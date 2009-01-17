#import "Core/NPObject/NPObject.h"

@interface ODSceneManager : NPObject
{
    id scenes;
    id currentScene;
    id renderTargetConfiguration;
    id pbo;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) createRenderTargets;

- (id) loadSceneFromPath:(NSString *)path;
- (id) loadSceneFromAbsolutePath:(NSString *)path;

- (id) currentScene;
- (id) renderTargetConfiguration;
- (id) pbo;

- (void) setCurrentScene:(id)newCurrentScene;

- (void) update;
- (void) render;

@end
