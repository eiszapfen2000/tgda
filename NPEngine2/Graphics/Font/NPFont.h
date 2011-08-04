#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

typedef struct NpBMFontCharacter
{
	int32_t x;
	int32_t y;
	int32_t width;
	int32_t height;
	int32_t xOffset;
	int32_t yOffset;
	int32_t xAdvance;
	int32_t characterMapIndex;
}
NpBMFontCharacter;

typedef struct NpFontCharacter
{
	FRectangle source; // coordinates to look up character in texture
	IVector2 size;
	IVector2 offset;	
	int32_t xAdvance;
	int32_t characterMapIndex;
}
NpFontCharacter;

@interface NPFont : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NSString * fontFaceName;
    int32_t renderedSize;
    int32_t lineHeight;
    int32_t baseLine;
    int32_t textureWidth;
    int32_t textureHeight;
    NSMutableArray * characterPages;
    NpFontCharacter * characters;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;

- (NSString *) fontFaceName;
- (int32_t) renderedSize;
- (int32_t) lineHeight;
- (int32_t) baseLine;
- (int32_t) textureWidth;
- (int32_t) textureHeight;

- (void) setFontFaceName:(NSString *)newFontFaceName;
- (void) setRenderedSize:(const int32_t)newRenderedSize;
- (void) setLineHeight:(const int32_t)newLineHeight;
- (void) setBaseLine:(const int32_t)newBaseLine;
- (void) setTextureWidth:(const int32_t)newTextureWidth;
- (void) setTextureHeight:(const int32_t)newTextureHeight;

- (void) addCharacterPageFromFile:(NSString *)fileName;
- (void) addCharacter:(const NpBMFontCharacter)character
              atIndex:(const int32_t)index
                     ;

@end

