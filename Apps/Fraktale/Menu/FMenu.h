#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

#define F_MENUITEM_ALIGNMENT_TOPLEFT       0
#define F_MENUITEM_ALIGNMENT_TOP           1
#define F_MENUITEM_ALIGNMENT_TOPRIGHT      2
#define F_MENUITEM_ALIGNMENT_RIGHT         3
#define F_MENUITEM_ALIGNMENT_BOTTOMRIGHT   4
#define F_MENUITEM_ALIGNMENT_BOTTOM        5
#define F_MENUITEM_ALIGNMENT_BOTTOMLEFT    6
#define F_MENUITEM_ALIGNMENT_LEFT          7

@class NPFont;
@class NPEffect;
@class NPTexture;
@class NPInputAction;

@interface FMenu : NPObject
{
    NSMutableDictionary * keywordMappings;
    NSMutableDictionary * textures;
    NSMutableDictionary * menuItems;

    NPInputAction * menuActivationAction;
    NPInputAction * menuClickAction;
    BOOL menuActive;

    BOOL foundHit;

    NPFont * font;
    NPEffect * effect;
}

+ (void) alignRectangle:(FRectangle *)rectangle withAlignment:(NpState)alignment;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (NPFont *) font;
- (NPEffect *) effect;
- (NPTexture *) textureForKey:(NSString *)key;

- (BOOL) foundHit;
- (id) menuItemWithName:(NSString *)itemName;
- (id) valueForKeyword:(NSString *)keyword;

- (void) update:(Float)frameTime;
- (void) render;

@end
