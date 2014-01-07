#import "NPFontManager.h"
#import "NPFont.h"

#import "NP.h"

@implementation NPFontManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPFontManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    fonts = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ fonts removeAllObjects ];
    [ fonts release ];

    [ super dealloc ];
}

- (id) loadFontFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadFontFromAbsolutePath:absolutePath ];
}

- (id) loadFontFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPFont * font = [ fonts objectForKey:path ];

        if ( font == nil )
        {
            NPLOG(@"");
            NPLOG(@"%@: loading %@", name, path);

            NPFont * font = [[ NPFont alloc ] initWithName:@"" parent:self ];

            if ( [ font loadFromPath:path ] == YES )
            {
                [ fonts setObject:font forKey:path ];
                [ font release ];

                return font;
            }
            else
            {
                [ font release ];

                return nil;
            }
        }

        return font;
    }

    return nil; 
}

@end
