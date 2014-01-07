#import "NP.h"
#import "ODMenu.h"
#import "ODSelectionGroup.h"

@implementation ODSelectionGroup

- (id) init
{
    return [ self initWithName:@"ODSelectionGroup" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    boundingRectangle = frectangle_alloc_init();
    rows = columns = activeItem = -1;

    textures = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ textures removeAllObjects ];
    [ textures release ];

    SAFE_FREE(items);

    frectangle_free(boundingRectangle);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary
{
    description = [[ dictionary objectForKey:@"Description" ] retain ];

    NSArray * positionStrings    = [ dictionary objectForKey:@"Position" ];
    NSArray * itemSizeStrings    = [ dictionary objectForKey:@"ItemSize" ];
    NSArray * itemSpacingStrings = [ dictionary objectForKey:@"ItemSpacing" ];
    NSArray * textureStrings     = [ dictionary objectForKey:@"Textures" ];

    NSString * rowsString      = [ dictionary objectForKey:@"Rows" ];
    NSString * columnsString   = [ dictionary objectForKey:@"Columns" ];
    NSString * alignmentString = [ dictionary objectForKey:@"Alignment" ];

    NSString * targetObjectString   = [ dictionary objectForKey:@"TargetObject" ];
    NSString * targetPropertyString = [ dictionary objectForKey:@"TargetProperty" ];

    if ( positionStrings == nil || itemSizeStrings == nil || itemSpacingStrings == nil ||
         textureStrings == nil || rowsString == nil || columnsString == nil || alignmentString == nil )
    {
        NPLOG_ERROR(@"%@: Dictionary incomplete.", name);
        return NO;
    }

    FVector2 position, itemSize, itemSpacing;

    position.x = [[ positionStrings objectAtIndex:0 ] floatValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] floatValue ];
    itemSize.x = [[ itemSizeStrings objectAtIndex:0 ] floatValue ];
    itemSize.y = [[ itemSizeStrings objectAtIndex:1 ] floatValue ];
    itemSpacing.x = [[ itemSpacingStrings objectAtIndex:0 ] floatValue ];
    itemSpacing.y = [[ itemSpacingStrings objectAtIndex:1 ] floatValue ];

    rows    = [ rowsString    intValue ];
    columns = [ columnsString intValue ];

    alignment = [[ (ODMenu *)parent valueForKeyword:alignmentString ] intValue ];

    // calculate size and init bounding rectangle
    FVector2 boundingRectangleSize = { 0.0f, 0.0f };
    for ( Int32 j = 0; j < columns; j++ )
    {
        boundingRectangleSize.x = boundingRectangleSize.x + itemSize.x + itemSpacing.x;
    }

    for ( Int32 i = 0; i < rows; i++ )
    {
        boundingRectangleSize.y = boundingRectangleSize.y + itemSize.y + itemSpacing.y;
    }

    FVector2 boundingRectangleLowerLeft;
    boundingRectangleLowerLeft.x = position.x;
    boundingRectangleLowerLeft.y = position.y - ((rows - 1) * (itemSize.y + itemSpacing.y));

    frectangle_vv_init_with_min_and_size_r(&boundingRectangleLowerLeft, &boundingRectangleSize, boundingRectangle);
    [ ODMenu alignRectangle:boundingRectangle withAlignment:alignment ];

    // Alloc items geometry and calculate coordinates
    Int32 numberOfItems = rows * columns;
    items = ALLOC_ARRAY(FRectangle, numberOfItems);

    FVector2 lowerLeft = position;

    for ( Int32 i = 0; i < rows; i++ )
    {
        lowerLeft.x = position.x;
        lowerLeft.y = lowerLeft.y - (i * (itemSize.y + itemSpacing.y));

        for ( Int32 j = 0; j < columns; j++ )
        {
            Int32 index = i * columns + j;
            frectangle_vv_init_with_min_and_size_r(&lowerLeft, &itemSize, &(items[index]));
            [ ODMenu alignRectangle:&(items[index]) withAlignment:alignment ];

            lowerLeft.x = lowerLeft.x + itemSize.x + itemSpacing.x;
        }
    }

    // Reflection stuff
    if ( targetObjectString != nil )
    {
        target = [[[ NP Core ] objectManager ] objectByName:targetObjectString ];
        NSAssert1(target != nil, @"Object with name \"%@\" not found", targetObjectString);

        if ( targetPropertyString != nil )
        {
            BOOL propertyFound = GSObjCFindVariable(target, [ targetPropertyString cStringUsingEncoding:NSASCIIStringEncoding ], NULL, &size, &offset );
            NSAssert1(propertyFound != NO, @"Property with name \"%@\" not found", targetPropertyString);
        }
    }

    // Load textures
    NSEnumerator * textureStringEnumerator = [ textureStrings objectEnumerator ];
    NSString * textureString = nil;

    while ( (textureString = [ textureStringEnumerator nextObject ]) )
    {
        id texture =  [[[ NP Graphics ] textureManager ] loadTextureFromPath:textureString ];

        if ( texture != nil )
        {
            [ textures addObject:texture ];
        }
    }

    selectionTexture = [ (ODMenu *)parent textureForKey:@"SelectedItem" ];
    effect = [ (ODMenu *)parent effect ];

    activeItem = 0;

    return YES;
}

- (Int32) activeItem
{
    return activeItem;
}

- (BOOL) mouseHit:(FVector2)mousePosition
{
    BOOL result = NO;

    if ( frectangle_vr_is_point_inside(&mousePosition, boundingRectangle) == 1 )
    {
        result = YES;
    }

    return result;
}

- (void) onClick:(FVector2)mousePosition
{
    for ( Int32 i = 0; i < rows; i++ )
    {
        for ( Int32 j = 0; j < columns; j++ )
        {
            Int32 index = i * columns + j;

            if ( frectangle_vr_is_point_inside(&mousePosition, &(items[index])) == 1 )
            {
                activeItem = index;
            }
        }
    }
}

- (void) render
{
    if ( effect == nil || [ textures count ] == 0)
    {
        return;
    }

    // Render description
    FVector2 position = { boundingRectangle->min.x, boundingRectangle->max.y + 0.035f };
    [[ (ODMenu *)parent font ] renderString:description atPosition:&position withSize:0.035f ];

    // Render items
    for ( Int32 i = 0; i < rows; i++ )
    {
        for ( Int32 j = 0; j < columns; j++ )
        {
            Int32 index = i * columns + j;

            [[ textures objectAtIndex:index ] activateAtColorMapIndex:0 ];
            [ effect activate ];

            [ NPPrimitivesRendering renderFRectangle:&(items[index]) ];

            [ effect deactivate ];
        }
    }

    // Render highlight for activa item
    [ selectionTexture activateAtColorMapIndex:0 ];
    [ effect activate ];

    [ NPPrimitivesRendering renderFRectangle:&(items[activeItem]) ];

    [ effect deactivate ];
}

@end

