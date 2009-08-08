#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface ODMenu : NPObject
{
    NSMutableDictionary * keywordMappings;
    NSMutableDictionary * textures;
    NSMutableDictionary * menuItems;

    id menuActivationAction;
    id menuClickAction;
    BOOL menuActive;

    BOOL foundHit;

    id menuEffect;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (id) menuEffect;
- (id) textureForKey:(NSString *)key;

- (BOOL) foundHit;
- (id) menuItemWithName:(NSString *)itemName;
- (id) valueForKeyword:(NSString *)keyword;

- (void) update:(Float)frameTime;
- (void) render;

@end
