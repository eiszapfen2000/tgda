#import <Foundation/NSException.h>
#import "Core/String/NPStringList.h"
#import "NPFont.h"
#import "NPFontCompiler.h"

@interface NPFontCompiler (Private)

- (void) parseInfoAtLine:(const NSUInteger)lineIndex;
- (void) parseCommonAtLine:(const NSUInteger)lineIndex;
- (void) parsePageAtLine:(const NSUInteger)lineIndex;
- (void) parseCharactersStartingAtLine:(const NSUInteger)lineIndex;

@end

@implementation NPFontCompiler (Private)

- (void) parseInfoAtLine:(const NSUInteger)lineIndex
{
    NSString * fontFaceName = nil;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:1 equalToString:@"face" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:2 equalToString:@"=" ] == YES
         && [ self getTokenAsString:&fontFaceName fromLine:lineIndex atPosition:3 ] == YES )
    {
        [ font setFontFaceName:fontFaceName ];
    }

    int32_t renderedSize = 0;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:4 equalToString:@"size" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:5 equalToString:@"=" ] == YES
         && [ self getTokenAsInt:&renderedSize fromLine:lineIndex atPosition:6 ] == YES )
    {
        [ font setRenderedSize:renderedSize ];
    }
}
        

- (void) parseCommonAtLine:(const NSUInteger)lineIndex
{
    int32_t lineHeight = -1;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:1 equalToString:@"lineheight" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:2 equalToString:@"=" ] == YES
         && [ self getTokenAsInt:&lineHeight fromLine:lineIndex atPosition:3 ] == YES )
    {
        [ font setLineHeight:lineHeight ];
    }

    int32_t baseLine = -1;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:4 equalToString:@"base" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:5 equalToString:@"=" ] == YES
         && [ self getTokenAsInt:&baseLine fromLine:lineIndex atPosition:6 ] == YES )
    {
        [ font setBaseLine:baseLine ];
    }

    int32_t textureWidth = -1;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:7 equalToString:@"scalew" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:8 equalToString:@"=" ] == YES
         && [ self getTokenAsInt:&textureWidth fromLine:lineIndex atPosition:9 ] == YES )
    {
        [ font setTextureWidth:textureWidth ];
    }

    int32_t textureHeight = -1;
    if ( [ self isLowerCaseTokenFromLine:lineIndex atPosition:10 equalToString:@"scaleh" ] == YES
         && [ self isTokenFromLine:lineIndex atPosition:11 equalToString:@"=" ] == YES
         && [ self getTokenAsInt:&textureHeight fromLine:lineIndex atPosition:12 ] == YES )
    {
        [ font setTextureHeight:textureHeight ];
    }
}

- (void) parsePageAtLine:(const NSUInteger)lineIndex
{
}

- (void) parseCharactersStartingAtLine:(const NSUInteger)lineIndex
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

    const NSUInteger numberOfLines = [ inputScript count ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        NSString * token = nil;
        if ( [ self getTokenAsLowerCaseString:&token
                                     fromLine:i
                                   atPosition:0 ] == YES )
        {
            if ( [ token isEqualToString:@"info" ] == YES )
            {
                [ self parseInfoAtLine:i ];
            }

            if ( [ token isEqualToString:@"common" ] == YES )
            {
                [ self parseCommonAtLine:i ];
            }

            if ( [ token isEqualToString:@"page" ] == YES )
            {
                [ self parsePageAtLine:i ];
            }

            if ( [ token isEqualToString:@"chars" ] == YES )
            {
                [ self parseCharactersStartingAtLine:i ];
            }

        }
    }

    DESTROY(font);
}

@end

