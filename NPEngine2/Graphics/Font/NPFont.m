#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/String/NPStringList.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableSampler.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
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
    [ self clear ];
    DESTROY(characterPages);

    [ super dealloc ];
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;

    SAFE_FREE(characters);
    SAFE_DESTROY(fontFaceName);
    [ characterPages removeAllObjects ];
    SAFE_DESTROY(technique);
    SAFE_DESTROY(characterPage);
    SAFE_DESTROY(textcolor);
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
    NSDictionary * arguments
        = [ NSDictionary dictionaryWithObject:@"nearest" forKey:@"Filter" ];

    NPTexture2D * page
        = [[[ NPEngineGraphics instance ] textures2D ]
                 getAssetWithFileName:fileName arguments:arguments];

    if ( page != nil )
    {
        [ characterPages addObject:page ];
    }
}

- (void) addCharacter:(const NpBMFontCharacter)character
              atIndex:(const int32_t)index
{
	if (index < 0 || index > 255)
	{
		return;
	}

	const float normaliseTextureCoordinatesX = 1.0f / (float)textureWidth;
	const float normaliseTextureCoordinatesY = 1.0f / (float)textureHeight;

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

	fontCharacter.characterPage = character.characterMapIndex;
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

    NPLOG(@"");
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

- (void) setEffectTechnique:(NPEffectTechnique *)newTechnique
{
    NSAssert(newTechnique != nil, @"");

    technique = RETAIN(newTechnique);

    characterPage = [[ technique effect ] variableWithName:@"characterpage" ];
    textcolor     = [[ technique effect ] variableWithName:@"textcolor"     ];
    ASSERT_RETAIN(characterPage);
    ASSERT_RETAIN(textcolor);
}

- (IVector2) boundsForString:(NSString *)string
                        size:(const int32_t)size
{
    NSAssert(string != nil, @"");

    const char * cString = [ string cStringUsingEncoding:NSASCIIStringEncoding ];

    NSAssert(cString != NULL, @"");

    IVector2 result = {0, 0};
    const float scale = ((float)size) / ((float)abs(renderedSize));

    NSUInteger numberOfCharacters = [ string length ];
    for ( NSUInteger i = 0; i < numberOfCharacters; i++ )
    {
        const int32_t character = cString[i];
        const NpFontCharacter fontCharacter = characters[character];

        result.x += (int32_t)round((float)fontCharacter.xAdvance * scale);
        result.y = MAX(result.y, (int32_t)round((float)(fontCharacter.offset.y + fontCharacter.size.y) * scale));
    }

    return result;
}

- (void) renderString:(NSString *)string
            withColor:(const FVector4)color
           atPosition:(const IVector2)position
                 size:(const int32_t)size
{
    NSAssert(ready && (characters != NULL) && ([ characterPages count ] != 0), @"");
    NSAssert(technique != nil, @"");

    const float scale = ((float)size) / ((float)abs(renderedSize));
    int32_t cursorPosition = position.x;

    NSUInteger numberOfCharacters = [ string length ];
    const char * cString = [ string cStringUsingEncoding:NSASCIIStringEncoding ];

    NSAssert(cString != NULL, @"");

    [ textcolor setValue:color ];
    [ technique activate ];

    NPTextureBindingState * texState
        = [[ NPEngineGraphics instance ] textureBindingState ];

    for ( NSUInteger i = 0; i < numberOfCharacters; i++ )
    {
        const int32_t character = cString[i];
        const NpFontCharacter fontCharacter = characters[character];

        IRectangle r;
        r.min.x = cursorPosition + (int32_t)round((float)fontCharacter.offset.x * scale);
		r.max.x = cursorPosition + (int32_t)round((float)(fontCharacter.size.x + fontCharacter.offset.x) * scale);
		r.max.y = position.y - (int32_t)round((float)fontCharacter.offset.y * scale);
		r.min.y = position.y - (int32_t)round((float)(fontCharacter.size.y + fontCharacter.offset.y) * scale);

        [ texState setTexture:[ characterPages objectAtIndex:fontCharacter.characterPage ] texelUnit:0 ];
        [ texState activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, fontCharacter.source.min.x, fontCharacter.source.min.y);
            glVertex2i(r.min.x, r.min.y);
            glVertexAttrib2f(NpVertexStreamTexCoords0, fontCharacter.source.max.x, fontCharacter.source.min.y);
            glVertex2i(r.max.x, r.min.y);
            glVertexAttrib2f(NpVertexStreamTexCoords0, fontCharacter.source.max.x, fontCharacter.source.max.y);
            glVertex2i(r.max.x, r.max.y);
            glVertexAttrib2f(NpVertexStreamTexCoords0, fontCharacter.source.min.x, fontCharacter.source.max.y);
            glVertex2i(r.min.x, r.max.y);
        glEnd();

		cursorPosition += (int32_t)round((float)fontCharacter.xAdvance * scale);
    }
}

@end

