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

    characterWidths = ALLOC_ARRAY(Float, 256);
    effect  = nil;
    texture = nil;

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
        //NSLog([characterWidthsLine description]);

        if ( [ characterWidthsLine count ] != 16 )
        {
            NPLOG_ERROR(@"%@: CharWidths Line must contain 16 elements", name);
            return NO;
        }

        Float textureWidth = (Float)[ texture width ];

        for ( Int j = 0; j < 16; j++ )
        {
            Int index = i * 16 + j;
            characterWidths[index] = ([[ characterWidthsLine objectAtIndex:j ] floatValue ] / textureWidth) * 16.0f;
            //NSLog(@"%f",characterWidths[index]);
        }
    }

    [ config release ];

    return YES;
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

    NPTextureBindingState * t = [[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ];
    [ t setTexture:texture forKey:@"NPCOLORMAP0" ];

    /*for ( UInt i = 0; i < [ string length ]; i++ )
    {
        unichar c = [ string characterAtIndex:i ];
        Int row = c / 16;
        Int column = c % 16;
        //NSLog(@"%d %d",row,column);
    }*/

    FVector2 pos = *position;

    [ effect activate ];

    for ( UInt i = 0; i < [ string length ]; i++ )
    {
        unichar u = [ string characterAtIndex:i ];
        Int row = u / 16;
        Int column = u % 16;
        Float tmp = 1.0f/16.0f;
        Float r = (Float)row * tmp;
        Float c = (Float)column * tmp;

        glBegin(GL_QUADS);
            glTexCoord2f(c,r);
            glVertex4f(pos.x, pos.y, 0.0f, 1.0f);

            glTexCoord2f(c,r+tmp);
            glVertex4f(pos.x, pos.y-1.0f*size, 0.0f, 1.0f);

            glTexCoord2f(c+tmp,r+tmp);
            glVertex4f(pos.x+1.0f*size, pos.y-1.0f*size, 0.0f, 1.0f);

            glTexCoord2f(c+tmp,r);
            glVertex4f(pos.x+1.0f*size, pos.y, 0.0f, 1.0f);
        glEnd();

        pos.x = pos.x + 1.0f*size;
    }

    [ effect deactivate ];
}

@end

