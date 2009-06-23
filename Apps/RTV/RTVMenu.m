#import "NP.h"
#import "RTVCore.h"
#import "RTVCheckBoxItem.h"
#import "RTVSelectionGroup.h"
#import "RTVSliderItem.h"
#import "RTVFluid.h"
#import "RTVScene.h"
#import "RTVMenu.h"

@implementation RTVMenu

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

    projection = fm4_alloc_init();
    identity   = fm4_alloc_init();
    fm4_mssss_orthographic_2d_projection_matrix(projection, 0.0f, 1.0f, 0.0f, 1.0f);

    foundHit = NO;

    menuItems = [[ NSMutableDictionary alloc ] init ];

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:@"tahoma.font" ];

    menuEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Menu.cgfx" ];
    scale = [ menuEffect parameterWithName:@"scale" ];

    menuActivationAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"MenuActivation" primaryInputAction:NP_INPUT_KEYBOARD_M ];
    menuActive = NO;

    menuClickAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"MenuClick" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT ];

    blendTime = 1.0f;
    currentBlendTime = 0.0f;
    blendStartTime = 0.0f;

    return self;
}

- (void) dealloc
{
    [ menuItems removeAllObjects ];
    [ menuItems release ];

    fm4_free(projection);
    fm4_free(identity);

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

    NSEnumerator * keyEnumerator = [ menu keyEnumerator ];
    NSString *  key;
    NSDictionary * itemData;
    NSString * itemType;
    Class itemClass;

    while ( (key = [ keyEnumerator nextObject ]) )
    {
        itemData = [ menu objectForKey:key ];

        itemType = [ itemData objectForKey:@"Type" ];
        itemClass = NSClassFromString(itemType);

        id item = [[ itemClass alloc ] initWithName:key parent:self ];

        if ( [ item loadFromDictionary:itemData ] == YES )
        {
            [ menuItems setObject:item forKey:key ];
        }

        [ item release ];
    }

    return YES;    
}

- (BOOL) foundHit
{
    return foundHit;
}

- (id) menuItemWithName:(NSString *)itemName
{
    return [ menuItems objectForKey:itemName ];
}

- (void) updateInkColor
{
        Int32 activeItem = [[ menuItems objectForKey:@"InkColors" ] activeItem ];
        FVector4 color;

        switch ( activeItem )
        {
            case 0:
            {
                color.x = 1.0f;
                color.y = 0.2f;
                color.z = 0.1f;
                color.w = 1.0f;
                break;
            }

            case 1:
            {
                color.x = 0.2f;
                color.y = 0.3f;
                color.z = 1.0f;
                color.w = 1.0f;
                break;
            }

            case 2:
            {
                color.x = 0.2f;
                color.y = 1.0f;
                color.z = 0.3f;
                color.w = 1.0f;
                break;
            }

            case 3:
            {
                color.x = 1.0f;
                color.y = 1.0f;
                color.z = 0.2f;
                color.w = 1.0f;
                break;
            }
        }

        [[(RTVScene *)parent fluid ] setInkColor:color ];
}

- (void) updateInputRadius
{
        Int32 activeItem = [[ menuItems objectForKey:@"InputRadius" ] activeItem ];
        Float inputRadius;

        switch ( activeItem )
        {
            case 0:
            {
                inputRadius = 5.0f;
                break;
            }

            case 1:
            {
                inputRadius = 47.0f;
                break;
            }

            case 2:
            {
                inputRadius = 101.0f;
                break;
            }
        }

        [[(RTVScene *)parent fluid ] setInputRadius:inputRadius ];    
}

- (void) updateViscosity
{
    RTVSliderItem * viscositySlider = [ menuItems objectForKey:@"ViscositySlider" ];
    Float scaleValue = [ viscositySlider scaleFactor ];

    [[(RTVScene *)parent fluid ] setViscosity:0.05 * scaleValue ];

}

- (void) updateBoundaries
{
    RTVCheckBoxItem * boundariesCheckBox = [ menuItems objectForKey:@"ArbitraryBoundaries" ];
    BOOL checked = [ boundariesCheckBox checked ];

    [[(RTVScene *)parent fluid ] setArbitraryBoundaries:checked ];    
}

- (void) update:(Float)frameTime
{
    if ( [ menuActivationAction activated ] == YES )
    {
        if ( menuActive == NO )
        {
            menuActive = YES;
            blendStartTime   = [[[ NP Core ] timer ] totalElapsedTime ];
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

            Float mouseX = [[[ NP Input ] mouse ] x ];
            Float mouseY = [[[ NP Input ] mouse ] y ];

            FVector2 normalisedMousePosition;

            // shift to pixel center using + 0.5
            normalisedMousePosition.x = (mouseX + 0.5) / (Float)(controlSize->x);
            normalisedMousePosition.y = (mouseY + 0.5) / (Float)(controlSize->y);

            NSEnumerator * menuItemEnumerator = [ menuItems objectEnumerator ];
            id menuItem;
            foundHit = NO;

            while ( (menuItem = [ menuItemEnumerator nextObject ]) && foundHit == NO )
            {
                foundHit = [ menuItem mouseHit:normalisedMousePosition ];

                if ( foundHit == YES )
                {
                    [ menuItem onClick:normalisedMousePosition ];
                }
            }
        }

        [ self updateInkColor ];
        [ self updateInputRadius ];
        [ self updateViscosity ];
        [ self updateBoundaries ];
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

        FVector2 fpsPosition = {0.9f, 0.95f };
        [ font renderString:[ NSString stringWithFormat:@"%d", [[[ NP Core ] timer ] fps ]] atPosition:&fpsPosition withSize:0.04f ];

        FVector2 colorPosition = {-0.97f, 0.95f};
        [ font renderString:@"Ink Color" atPosition:&colorPosition withSize:0.04f ];

        FVector2 splatRadiusPosition = {-0.97f, 0.55f};
        [ font renderString:@"Splat Radius" atPosition:&splatRadiusPosition withSize:0.04f ];

        FVector2 viscosityPosition = {-0.97f, 0.25f};
        [ font renderString:@"Viscosity" atPosition:&viscosityPosition withSize:0.04f ];

        FVector2 arbitraryBoundariesPosition = {-0.97f, 0.0f};
        [ font renderString:@"Boundaries" atPosition:&arbitraryBoundariesPosition withSize:0.04f ];

        FVector2 dataArraysPosition = {-0.97f, -0.25f};
        [ font renderString:@"Arrays" atPosition:&dataArraysPosition withSize:0.04f ];

    }
}

@end

