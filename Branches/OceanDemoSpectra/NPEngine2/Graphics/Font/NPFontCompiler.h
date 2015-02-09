#import "Core/String/NPParser.h"

@class NPFont;
@class NPStringList;

@interface NPFontCompiler : NPParser
{
    NPFont * font;
}

- (void) compileScript:(NPStringList *)inputScript
              intoFont:(NPFont *)targetFont
                      ;

@end
