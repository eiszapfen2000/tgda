#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

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

@end

