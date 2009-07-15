#import "NPFont.h"
#import "NP.h"

@implementation NPFont

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPFont" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    characterWidths = ALLOC_ARRAY(Byte, 256);

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(effect);
    TEST_RELEASE(texture);
    SAFE_FREE(characterWidths);

    [ super dealloc ];
}

- (NPEffect *) effect
{
    return effect;
}

- (NPTexture *) texture
{
    return texture;
}

- (void) setEffect:(NPEffect *)newEffect
{
    ASSIGN(effect, newEffect);
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * config = [[ NSDictionary alloc ] initWithContentsOfFile:path];

    [ self setName:[ config objectForKey:@"Name" ]];

    NSString * textureFileName = [ config objectForKey:@"Texture" ];
    NSString * effectFileName  = [ config objectForKey:@"Effect"  ];
    texture = [[[[ NP Graphics ] textureManager ] loadTextureFromPath:textureFileName ] retain ];
    effect  = [[[[ NP Graphics ] effectManager  ] loadEffectFromPath :effectFileName  ] retain ];

    for ( Int i = 0; i < 16; i++ )
    {
        NSArray * characterWidthsLine = [ config objectForKey:[NSString stringWithFormat:@"CharWidths%d", i ]];

        if ( [ characterWidthsLine count ] != 16 )
        {
            NPLOG_ERROR(@"%@: CharWidths Line must contain 16 elements", name);
            return NO;
        }

        for ( Int j = 0; j < 16; j++ )
        {
            Int index = i * 16 + j;
            characterWidths[index] = (Byte)[[ characterWidthsLine objectAtIndex:j ] intValue ];
        }
    }

    [ config release ];

    return YES;
}

- (Float) calculateTextWidth:(NSString *)text
                  usingSize:(Float)size
{
    Float width = 0.0f;

    div_t tmp = div([ texture width ], 16);
    Float widthInTexture = (Float)tmp.quot;

    for ( UInt i = 0; i < [ text length ]; i++ )
    {
        unichar u = [ text characterAtIndex:i ];
        width = width + ( (Float)characterWidths[u] / widthInTexture ) * 2.0f;
    }

    return width * size;
}

- (void) renderString:(NSString *)string atPosition:(FVector2 *)position withSize:(Float)size
{
    FVector4 color = {1.0f,1.0f,1.0f,1.0f};

    [ self renderString:string
            atPosition:position
         withAlignment:NP_GRAPHICS_FONT_ALIGNMENT_LEFT
                  size:size
                 color:&color ];

    
}

- (void) renderString:(NSString *)string
           atPosition:(FVector2 *)position
        withAlignment:(NpState)alignment
                 size:(Float)size
                color:(FVector4 *)color
{
    if ( [ string length ] == 0 )
    {
        return;
    }

    if ( texture == nil || effect == nil )
    {
        NPLOG_ERROR(@"%@: texture or effect missing", name);
        return;
    }

    FVector2 origin = *position;

    switch ( alignment )
    {
        case NP_GRAPHICS_FONT_ALIGNMENT_LEFT:
        {
            break;
        }

        case NP_GRAPHICS_FONT_ALIGNMENT_CENTER:
        {
            origin.x = origin.x - [ self calculateTextWidth:string usingSize:size ] * 0.5f;
            break;
        }

        case NP_GRAPHICS_FONT_ALIGNMENT_RIGHT:
        {
            origin.x = origin.x - [ self calculateTextWidth:string usingSize:size ];
            break;
        }

        default:
        {
            NPLOG_ERROR(@"%@: Unknown text alignment", name);
            return;
        }
    }

    NPTextureBindingState * t = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];
    [ t setTexture:texture forKey:@"NPCOLORMAP0" ];

    [ effect activate ];

    unichar character;
    Float characterWidth;
    FVector2 texCoordUpperLeft;
    FVector2 texCoordLowerRight;

    div_t tmp = div([ texture width ], 16);
    Float characterWidthInTexture = (Float)tmp.quot;

    FVector2 pos = origin;

    UInt characterCount = [ string length ];

    for ( UInt i = 0; i < characterCount; i++ )
    {
        character = [ string characterAtIndex:i ];
        characterWidth = ( (Float)characterWidths[character] / characterWidthInTexture ) * size;

        tmp = div(character, 16);
        Int row = tmp.quot;
        Int column = character % 16;

        texCoordUpperLeft.x = (Float)column / 16.0f;
        texCoordUpperLeft.y = 1.0f - ( (Float)row / 16.0f );
        texCoordLowerRight.x = (Float)(column + 1) / 16.0f;
        texCoordLowerRight.y = 1.0f - ( (Float)(row + 1) / 16.0f );

        pos.x = pos.x + characterWidth;

        glBegin(GL_QUADS);

            glTexCoord2f(texCoordUpperLeft.x, texCoordUpperLeft.y);
            glVertex4f(pos.x - size, pos.y + size, 0.0f, 1.0f);
            //NSLog(@"1 %f %f",pos.x - size,pos.x + size);

            glTexCoord2f(texCoordLowerRight.x, texCoordUpperLeft.y);
            glVertex4f(pos.x + size, pos.y + size, 0.0f, 1.0f);
            //NSLog(@"2 %f %f",pos.x + size,pos.x + size);

            glTexCoord2f(texCoordLowerRight.x, texCoordLowerRight.y);
            glVertex4f(pos.x + size, pos.y - size, 0.0f, 1.0f);
            //NSLog(@"3 %f %f",pos.x + size,pos.x - size);

            glTexCoord2f(texCoordUpperLeft.x, texCoordLowerRight.y);
            glVertex4f(pos.x - size, pos.y - size, 0.0f, 1.0f);
            //NSLog(@"4 %f %f",pos.x - size,pos.x - size);

        glEnd();

        pos.x = pos.x + characterWidth;
    }

    [ effect deactivate ];
}

@end

