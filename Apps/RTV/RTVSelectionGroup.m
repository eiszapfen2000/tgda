#import "NP.h"
#import "RTVCore.h"
#import "RTVSelectionGroup.h"

@implementation RTVSelectionGroup

- (id) init
{
    return [ self initWithName:@"RTVSelectionGroup" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    position = fv2_alloc_init();
    size = fv2_alloc_init();
    itemSize = fv2_alloc_init();
    spacing = fv2_alloc_init();

    textures = [[ NSMutableArray alloc ] init ];

    rows = columns = activeItem = -1;

    return self;
}

- (void) dealloc
{
    [ textures removeAllObjects ];
    [ textures release ];

    fv2_free(position);
    fv2_free(size);
    fv2_free(itemSize);
    fv2_free(spacing);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    NSArray * positionStrings = [ dictionary objectForKey:@"Position" ];
    position->x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position->y = [[ positionStrings objectAtIndex:1 ] floatValue ];

    NSArray * sizeStrings = [ dictionary objectForKey:@"ItemSize" ];
    itemSize->x = [[ sizeStrings objectAtIndex:0 ] floatValue ];
    itemSize->y = [[ sizeStrings objectAtIndex:1 ] floatValue ];

    NSArray * spacingStrings = [ dictionary objectForKey:@"Spacing" ];
    spacing->x = [[ spacingStrings objectAtIndex:0 ] floatValue ];
    spacing->y = [[ spacingStrings objectAtIndex:1 ] floatValue ];

    NSString * rowsString = [ dictionary objectForKey:@"Rows" ];
    NSString * columnsString = [ dictionary objectForKey:@"Columns" ];

    rows = [ rowsString intValue ];
    columns = [ columnsString intValue ];

    NSString * selectionTextureString = [ dictionary objectForKey:@"Selection" ];
    selectionTexture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:selectionTextureString ];

    NSArray * itemTextureStrings = [ dictionary objectForKey:@"Textures" ];
    NSEnumerator * textureStringEnumerator = [ itemTextureStrings objectEnumerator ];
    NSString * textureString = nil;

    while ( (textureString = [ textureStringEnumerator nextObject ]) )
    {
        id texture =  [[[ NP Graphics ] textureManager ] loadTextureFromPath:textureString ];

        if ( texture != nil )
        {
            [ textures addObject:texture ];
        }
    }

    NSString * effectString = [ dictionary objectForKey:@"Effect" ];
    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:effectString ];

    // calculate size

    Float width = 0.0;
    for ( Int32 j = 0; j < columns; j++ )
    {
        width = width + itemSize->x + spacing->x;
    }

    Float height = 0.0f;
    for ( Int32 i = 0; i < rows; i++ )
    {
        height = height + itemSize->y + spacing->y;
    }

    size->x = width;
    size->y = height;

    return YES;
}

- (FVector2) position
{
    return *position;
}

- (FVector2) itemSize
{
    return *itemSize;
}

- (void) setPosition:(FVector2)newPosition
{
    *position = newPosition;
}

- (void) setItemSize:(FVector2)newItemSize
{
    *itemSize = newItemSize;
}

- (BOOL) mouseHit:(FVector2)mousePosition
{
    BOOL result = NO;

    if ( mousePosition.x > position->x && mousePosition.x < position->x + size->x &&
         mousePosition.y < position->y && mousePosition.y > position->y - size->y )
    {
        result = YES;
    }

    return result;
}

- (void) onClick:(FVector2)mousePosition
{
    FVector2 upperLeft = *position;
    FVector2 lowerRight;

    for ( Int32 i = 0; i < rows; i++ )
    {
        for ( Int32 j = 0; j < columns; j++ )
        {
            Int32 index = i * rows + j;
            lowerRight.x = upperLeft.x + itemSize->x;
            lowerRight.y = upperLeft.y - itemSize->y;

            if ( mousePosition.x > upperLeft.x && mousePosition.x < lowerRight.x &&
                 mousePosition.y < upperLeft.y && mousePosition.y > lowerRight.y )
            {
                activeItem = index;
            }

            upperLeft.x = upperLeft.x + itemSize->x + spacing->x;
        }

        upperLeft.x = position->x;
        upperLeft.y = upperLeft.y - itemSize->y - spacing->y;
    }
}

- (void) update:(Float)frameTime
{

}

- (void) render
{
    if ( effect == nil || [ textures count ] == 0)
    {
        return;
    }

    FVector2 upperLeft = *position;
    FVector2 lowerRight;

    for ( Int32 i = 0; i < rows; i++ )
    {
        for ( Int32 j = 0; j < columns; j++ )
        {
            Int32 index = i * rows + j;
            [[ textures objectAtIndex:index ] activateAtColorMapIndex:0 ];
            [ effect activate ];

            lowerRight.x = upperLeft.x + itemSize->x;
            lowerRight.y = upperLeft.y - itemSize->y;

            glBegin(GL_QUADS);

            glTexCoord2f(0.0f, 1.0f);
            glVertex4f(upperLeft.x, upperLeft.y, 0.0f, 1.0f);

            glTexCoord2f(0.0f, 0.0f);
            glVertex4f(upperLeft.x, lowerRight.y, 0.0f, 1.0f);

            glTexCoord2f(1.0f, 0.0f);
            glVertex4f(lowerRight.x, lowerRight.y, 0.0f, 1.0f);

            glTexCoord2f(1.0f, 1.0f);
            glVertex4f(lowerRight.x, upperLeft.y, 0.0f, 1.0f);

            glEnd();

            if ( index == activeItem )
            {
                [ selectionTexture activateAtColorMapIndex:0 ];
                [ effect activate ];

                glBegin(GL_QUADS);

                glTexCoord2f(0.0f, 1.0f);
                glVertex4f(upperLeft.x, upperLeft.y, 0.0f, 1.0f);

                glTexCoord2f(0.0f, 0.0f);
                glVertex4f(upperLeft.x, lowerRight.y, 0.0f, 1.0f);

                glTexCoord2f(1.0f, 0.0f);
                glVertex4f(lowerRight.x, lowerRight.y, 0.0f, 1.0f);

                glTexCoord2f(1.0f, 1.0f);
                glVertex4f(lowerRight.x, upperLeft.y, 0.0f, 1.0f);

                glEnd();
            }

            upperLeft.x = upperLeft.x + itemSize->x + spacing->x;
        }

        upperLeft.x = position->x;
        upperLeft.y = upperLeft.y - itemSize->y - spacing->y;
    }

    [ effect deactivate ];
}

@end

