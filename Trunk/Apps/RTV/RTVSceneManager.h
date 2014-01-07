#import "Core/NPObject/NPObject.h"

@class RTVScene;

@interface RTVSceneManager : NPObject
{
    NSMutableDictionary * scenes;
    RTVScene * currentScene;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) clear;

- (id) loadSceneFromPath:(NSString *)path;
- (id) loadSceneFromAbsolutePath:(NSString *)path;

- (RTVScene *) currentScene;
- (void) setCurrentScene:(RTVScene *)newCurrentScene;

- (void) update:(Float)frameTime;
- (void) render;

@end
