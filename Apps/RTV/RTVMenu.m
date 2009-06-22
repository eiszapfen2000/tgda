#import "NP.h"
#import "RTVCore.h"
#import "RTVCheckBoxItem.h"
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

    menuItems = [[ NSMutableArray alloc ] init ];

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
            [ menuItems addObject:item ];
        }

        [ item release ];
    }

    return YES;    
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
            BOOL foundHit = NO;

            while ( (menuItem = [ menuItemEnumerator nextObject ]) && foundHit == NO )
            {
                foundHit = [ menuItem mouseHit:normalisedMousePosition ];

                if ( foundHit == YES )
                {
                    [ menuItem onClick:normalisedMousePosition ];
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

