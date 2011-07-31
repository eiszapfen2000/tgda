#import <Foundation/NSException.h>
#import "Core/String/NPStringList.h"
#import "NPFont.h"
#import "NPFontCompiler.h"

@interface NPFontCompiler (Private)

- (void) parseInfo;
- (void) parseCommon;
- (void) parsePages;
- (void) parseCharacters;

@end

@implementation NPFont (Private)

- (void) parseInfo
{
}

- (void) parseCommon
{
}

- (void) parsePages
{
}

- (void) parseCharacters
{
}

@end

@implementation NPFontCompiler

- (void) compileScript:(NPStringList *)inputScript
              intoFont:(NPFont *)targetFont
{
    NSAssert(inputScript != nil && targetFont != nil, @"");

    ASSIGN(font, targetFont);
    [ self parse:inputScript ];

    [ self parseInfo ];
    [ self parseCommon ];
    [ self parsePages ];
    [ self parseCharacters ];

    DESTROY(font);
}

@end

