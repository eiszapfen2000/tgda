#import "NP.h"
#import "ODSliderItem.h"
#import "ODMenu.h"

@implementation ODMenu

+ (FVector2) calculatePosition:(FVector2)position forAlignment:(NpState)alignment
{
    FVector2 result;

    switch ( alignment )
    {
        case OD_MENUITEM_ALIGNMENT_TOPLEFT:    { result = [ NPOrthographicRendering alignTopLeft:position     ]; break; }
        case OD_MENUITEM_ALIGNMENT_TOP:        { result = [ NPOrthographicRendering alignTop:position         ]; break; }
        case OD_MENUITEM_ALIGNMENT_TOPRIGHT:   { result = [ NPOrthographicRendering alignTopRight:position    ]; break; }
        case OD_MENUITEM_ALIGNMENT_RIGHT:      { result = [ NPOrthographicRendering alignRight:position       ]; break; }
        case OD_MENUITEM_ALIGNMENT_BOTTOMRIGHT:{ result = [ NPOrthographicRendering alignBottomRight:position ]; break; }
        case OD_MENUITEM_ALIGNMENT_BOTTOM:     { result = [ NPOrthographicRendering alignBottom:position      ]; break; }
        case OD_MENUITEM_ALIGNMENT_BOTTOMLEFT: { result = [ NPOrthographicRendering alignBottomLeft:position  ]; break; }
        case OD_MENUITEM_ALIGNMENT_LEFT:       { result = [ NPOrthographicRendering alignLeft:position        ]; break; }
    }

    return result;
}

+ (void) alignRectangle:(FRectangle *)rectangle withAlignment:(NpState)alignment
{
    FVector2 alignedMin;
    FVector2 alignedMax;

    switch ( alignment )
    {
        case OD_MENUITEM_ALIGNMENT_TOPLEFT:
        {
            rectangle->min = [ NPOrthographicRendering alignTopLeft:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignTopLeft:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_TOP:
        {
            rectangle->min = [ NPOrthographicRendering alignTop:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignTop:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_TOPRIGHT:
        {
            rectangle->min = [ NPOrthographicRendering alignTopRight:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignTopRight:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_RIGHT:
        {
            rectangle->min = [ NPOrthographicRendering alignRight:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignRight:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_BOTTOMRIGHT:
        {
            rectangle->min = [ NPOrthographicRendering alignBottomRight:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignBottomRight:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_BOTTOM:
        {
            rectangle->min = [ NPOrthographicRendering alignBottom:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignBottom:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_BOTTOMLEFT:
        {
            rectangle->min = [ NPOrthographicRendering alignBottomLeft:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignBottomLeft:rectangle->max ];
            break;
        }

        case OD_MENUITEM_ALIGNMENT_LEFT:
        {
            rectangle->min = [ NPOrthographicRendering alignLeft:rectangle->min ];
            rectangle->max = [ NPOrthographicRendering alignLeft:rectangle->max ];
            break;
        }
    }

    frectangle_r_recalculate_min_max(rectangle);
}

- (id) init
{
    return [ self initWithName:@"Menu" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    keywordMappings = [[ NSMutableDictionary alloc ] init ];

    [ keywordMappings setObject:[NSNumber numberWithInt:0] forKey:@"TopLeft" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:1] forKey:@"Top" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:2] forKey:@"TopRight" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:3] forKey:@"Right" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:4] forKey:@"BottomRight" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:5] forKey:@"Bottom" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:6] forKey:@"BottomLeft" ];
    [ keywordMappings setObject:[NSNumber numberWithInt:7] forKey:@"Left" ];

    textures = [[ NSMutableDictionary alloc ] init ];

    foundHit = NO;

    menuItems = [[ NSMutableDictionary alloc ] init ];

    menuClickAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"MenuClick" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT ];
    menuActivationAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"MenuActivation" primaryInputAction:NP_INPUT_KEYBOARD_M ];
    menuActive = NO;

    return self;
}

- (void) dealloc
{
    [ textures removeAllObjects ];
    [ textures release ];

    [ keywordMappings removeAllObjects ];
    [ keywordMappings release ];

    [ menuItems removeAllObjects ];
    [ menuItems release ];

    [ super dealloc ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    if ( [ absolutePath isEqual:@"" ] == YES )
    {
        return NO;
    }

    NSDictionary * menu = [ NSDictionary dictionaryWithContentsOfFile:absolutePath ];

    NSString * menuEffectString = [ menu objectForKey:@"Effect" ];
    if ( menuEffectString == nil )
    {
        NPLOG_ERROR(@"%@: Effect missing", name);
        return NO;
    }

    menuEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:menuEffectString ];

    NSDictionary * texturesDictionary = [ menu objectForKey:@"Textures" ];
    if ( texturesDictionary == nil )
    {
        NPLOG_ERROR(@"%@: Textures missing", name);
        return NO;
    }

    NSEnumerator * keyEnumerator = [ texturesDictionary keyEnumerator ];
    NSString * key;

    while ( (key = [ keyEnumerator nextObject ]) )
    {
        NSString * path = [ texturesDictionary objectForKey:key ];
        NPTexture * texture = [[[ NP Graphics ] textureManager ] loadTextureFromPath:path ];

        if ( texture != nil )
        {
            [ textures setObject:texture forKey:key ];
        }
    }

    NSDictionary * items = [ menu objectForKey:@"Items" ];
    if ( items == nil )
    {
        NPLOG_ERROR(@"%@: Items missing", name);
        return NO;
    }

    keyEnumerator = [ items keyEnumerator ];
    NSDictionary * itemData;
    NSString * itemType;
    Class itemClass;

    while ( (key = [ keyEnumerator nextObject ]) )
    {
        itemData = [ items objectForKey:key ];
        itemType = [ itemData objectForKey:@"Type" ];

        itemClass = NSClassFromString(itemType);
        NSAssert1(itemClass != Nil, @"Invalid Class Name %@", itemType);

        id item = [[ itemClass alloc ] initWithName:key parent:self ];

        if ( [ item loadFromDictionary:itemData ] == YES )
        {
            [ menuItems setObject:item forKey:key ];
        }

        [ item release ];
    }

    return YES;    
}

- (id) menuEffect
{
    return menuEffect;
}

- (id) textureForKey:(NSString *)key
{
    return [ textures objectForKey:key ];
}

- (BOOL) foundHit
{
    return foundHit;
}

- (id) menuItemWithName:(NSString *)itemName
{
    return [ menuItems objectForKey:itemName ];
}

- (id) valueForKeyword:(NSString *)keyword
{
    return [ keywordMappings objectForKey:keyword ];
}

- (void) update:(Float)frameTime
{
    if ( [ menuActivationAction activated ] == YES )
    {
        if ( menuActive == NO )
        {
            menuActive = YES;
        }
        else
        {
            menuActive = NO;
        }
    }

    if ( menuActive == YES )
    {
        if ( [ menuClickAction activated ] )
        {
            IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];
            Float aspectRatio = [[[ NP Graphics ] viewportManager ] currentAspectRatio ];

            Float mouseX = [[[ NP Input ] mouse ] x ];
            Float mouseY = [[[ NP Input ] mouse ] y ];

            FVector2 preProjectionMousePosition;

            // shift to pixel center using + 0.5
            preProjectionMousePosition.x = ((mouseX + 0.5f) / ((Float)(controlSize->x) / ( 2.0f * aspectRatio ))) - aspectRatio;
            preProjectionMousePosition.y = ((mouseY + 0.5f) / ((Float)(controlSize->y) / 2.0f )) - 1.0f;

            NSEnumerator * menuItemEnumerator = [ menuItems objectEnumerator ];
            id menuItem;
            foundHit = NO;

            while ( (menuItem = [ menuItemEnumerator nextObject ]) && foundHit == NO )
            {
                foundHit = [ menuItem mouseHit:preProjectionMousePosition ];

                if ( foundHit == YES )
                {
                    [ menuItem onClick:preProjectionMousePosition ];
                }
            }
        }
    }
}

- (void) render
{
    if ( menuActive == YES )
    {
        NSEnumerator * menuItemEnumerator = [ menuItems objectEnumerator ];
        id menuItem;

        while ( (menuItem = [ menuItemEnumerator nextObject ]) )
        {
            [ menuItem render ];
        }
    }
}

@end

