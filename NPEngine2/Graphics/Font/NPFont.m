#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/String/NPStringList.h"
#import "Core/NPEngineCore.h"
#import "NPFontCompiler.h"
#import "NPFont.h"

@interface NPFont (Private)

- (void) loadFromStringList:(NPStringList *)stringList;

@end

@implementation NPFont (Private)

- (void) loadFromStringList:(NPStringList *)stringList
{
    NSAssert(stringList != nil, @"");

    NPFontCompiler * compiler = [[ NPFontCompiler alloc ] init ];
    [ compiler compileScript:stringList intoFont:self ];
    DESTROY(compiler);

    ready = YES;
}

@end

@implementation NPFont

- (id) init
{
    return [ self initWithName:@"Font" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    fontFaceName = nil;
    renderedSize = 0;
    lineHeight = baseLine = 0;
    textureWidth = textureHeight = 0;
    characterPages = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ characterPages removeAllObjects ];
    DESTROY(characterPages);
    SAFE_DESTROY(file);

    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;

    SAFE_DESTROY(fontFaceName);
    [ characterPages removeAllObjects ];
    renderedSize = 0;
    lineHeight = baseLine = 0;
    textureWidth = textureHeight = 0;
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (NSString *) fontFaceName
{
    return fontFaceName;
}

- (int32_t) renderedSize
{
    return renderedSize;
}

- (int32_t) lineHeight
{
    return lineHeight;
}

- (int32_t) baseLine
{
    return baseLine;
}

- (int32_t) textureWidth
{
    return textureWidth;
}

- (int32_t) textureHeight
{
    return textureHeight;
}

- (void) setFontFaceName:(NSString *)newFontFaceName
{
    ASSIGNCOPY(fontFaceName, newFontFaceName);
}

- (void) setRenderedSize:(const int32_t)newRenderedSize
{
    renderedSize = newRenderedSize;
}

- (void) setLineHeight:(const int32_t)newLineHeight
{
    lineHeight = newLineHeight;
}

- (void) setBaseLine:(const int32_t)newBaseLine
{
    baseLine = newBaseLine;
}

- (void) setTextureWidth:(const int32_t)newTextureWidth
{
    textureWidth = newTextureWidth;
}

- (void) setTextureHeight:(const int32_t)newTextureHeight
{
    textureHeight = newTextureHeight;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{

    [ self clear ];

    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"Loading font \"%@\"", completeFileName);

    NPStringList * fontScript
        = AUTORELEASE([[ NPStringList alloc ]
                            initWithName:@"" 
                         allowDuplicates:YES
                       allowEmptyStrings:NO ]);

    if ( [ fontScript loadFromFile:completeFileName
                         arguments:nil
                             error:error ] == NO )
    {
        return NO;
    }

    [ self loadFromStringList:fontScript ];

    return YES;
}

@end

