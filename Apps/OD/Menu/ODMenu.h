#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define OD_MENUITEM_ALIGNMENT_TOPLEFT       0
#define OD_MENUITEM_ALIGNMENT_TOP           1
#define OD_MENUITEM_ALIGNMENT_TOPRIGHT      2
#define OD_MENUITEM_ALIGNMENT_RIGHT         3
#define OD_MENUITEM_ALIGNMENT_BOTTOMRIGHT   4
#define OD_MENUITEM_ALIGNMENT_BOTTOM        5
#define OD_MENUITEM_ALIGNMENT_BOTTOMLEFT    6
#define OD_MENUITEM_ALIGNMENT_LEFT          7

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

+ (FVector2) calculatePosition:(FVector2)position forAlignment:(NpState)alignment;
+ (void) alignRectangle:(FRectangle *)rectangle withAlignment:(NpState)alignment;

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
