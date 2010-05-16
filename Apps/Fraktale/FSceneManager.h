#import "Core/NPObject/NPObject.h"

@class FScene;

@interface FSceneManager : NPObject
{
    NSMutableDictionary * scenes;
    FScene * currentScene;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) clear;

- (id) loadSceneFromPath:(NSString *)path;
- (id) loadSceneFromAbsolutePath:(NSString *)path;

- (FScene *) currentScene;
- (void) setCurrentScene:(FScene *)newCurrentScene;

- (void) update:(Float)frameTime;
- (void) render;

@end
