#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/String/NPStringList.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/NPEngineGraphics.h"
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
    characters = NULL;

    return self;
}

- (void) dealloc
{
    [ characterPages removeAllObjects ];
    DESTROY(characterPages);
    SAFE_FREE(characters);
    SAFE_DESTROY(file);

    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;

    SAFE_FREE(characters);
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

- (void) addCharacterPageFromFile:(NSString *)fileName
{
    NPTexture2D * characterPage
        = [[[ NPEngineGraphics instance ] textures2D ] getAssetWithFileName:fileName ];

    if ( characterPage != nil )
    {
        [ characterPages addObject:characterPage ];
    }
}

- (void) addCharacter:(const NpBMFontCharacter)character
              atIndex:(const int32_t)index
{
	if (index < 0 || index > 255)
	{
		return;
	}

	const float normaliseTextureCoordinatesX = 1.0f / textureWidth;
	const float normaliseTextureCoordinatesY = 1.0f / textureHeight;

	// NpBMFontCharacter uses integer coordinates representing pixel centers
	// NpFontCharacter has it's origin at the lower left and uses normalised coordinates,
	// so we need to flip the ZtBMFontCharacter's y coordinates and normalise afterwards.
	NpFontCharacter fontCharacter;
	fontCharacter.source.min.x = (float)character.x + 0.5f;
	fontCharacter.source.min.y = (float)textureHeight - ((float)(character.y + character.height - 1) + 0.5f);
	fontCharacter.source.max.x = (float)(character.x + character.width - 1) + 0.5f;
	fontCharacter.source.max.y = (float)textureHeight - ((float)character.y + 0.5f);
	fontCharacter.source.min.x *= normaliseTextureCoordinatesX;
	fontCharacter.source.min.y *= normaliseTextureCoordinatesY;
	fontCharacter.source.max.x *= normaliseTextureCoordinatesX;
	fontCharacter.source.max.y *= normaliseTextureCoordinatesY;

	fontCharacter.characterMapIndex = character.characterMapIndex;
	fontCharacter.xAdvance = character.xAdvance;
    fontCharacter.size.x = character.width;
    fontCharacter.size.y = character.height;
	fontCharacter.offset.x = character.xOffset;
	fontCharacter.offset.y = character.yOffset;

    characters[index] = fontCharacter;
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

    characters = ALLOC_ARRAY(NpFontCharacter, 256);
    memset(characters, 0, sizeof(NpFontCharacter) * 256);

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

