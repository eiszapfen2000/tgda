#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NSArray+NPPPersistentObject.h"
#import "Graphics/NPOrthographic.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
#import "ODMenu.h"

@implementation ODMenu

+ (FRectangle) alignRectangle:(const FRectangle)rectangle
                withAlignment:(const NpOrthographicAlignment)alignment
{
    FRectangle result = rectangle;

    switch ( alignment )
    {
        case NpOrthographicAlignTopLeft:
        {
            result.min = [ NPOrthographic alignTopLeft:rectangle.min ];
            result.max = [ NPOrthographic alignTopLeft:rectangle.max ];
            break;
        }

        case NpOrthographicAlignTop:
        {
            result.min = [ NPOrthographic alignTop:rectangle.min ];
            result.max = [ NPOrthographic alignTop:rectangle.max ];
            break;
        }

        case NpOrthographicAlignTopRight:
        {
            result.min = [ NPOrthographic alignTopRight:rectangle.min ];
            result.max = [ NPOrthographic alignTopRight:rectangle.max ];
            break;
        }

        case NpOrthographicAlignRight:
        {
            result.min = [ NPOrthographic alignRight:rectangle.min ];
            result.max = [ NPOrthographic alignRight:rectangle.max ];
            break;
        }

        case NpOrthographicAlignBottomRight:
        {
            result.min = [ NPOrthographic alignBottomRight:rectangle.min ];
            result.max = [ NPOrthographic alignBottomRight:rectangle.max ];
            break;
        }

        case NpOrthographicAlignBottom:
        {
            result.min = [ NPOrthographic alignBottom:rectangle.min ];
            result.max = [ NPOrthographic alignBottom:rectangle.max ];
            break;
        }

        case NpOrthographicAlignBottomLeft:
        {
            result.min = [ NPOrthographic alignBottomLeft:rectangle.min ];
            result.max = [ NPOrthographic alignBottomLeft:rectangle.max ];
            break;
        }

        case NpOrthographicAlignLeft:
        {
            result.min = [ NPOrthographic alignLeft:rectangle.min ];
            result.max = [ NPOrthographic alignLeft:rectangle.max ];
            break;
        }

        default:
        {
            break;
        }
    }

    frectangle_r_recalculate_min_max(&result);
    return result;
}

- (id) init
{
    return [ self initWithName:@"Menu" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;

    textures = [[ NSMutableDictionary alloc ] init ];
    menuItems = [[ NSMutableArray alloc ] init ];
    menuActive = NO;


    menuClickAction
        = [[[ NPEngineInput instance ] inputActions ]
                addInputActionWithName:@"Menu Click"
                            inputEvent:NpMouseButtonLeft ];

    menuActivationAction
        = [[[ NPEngineInput instance ] inputActions ]
                addInputActionWithName:@"Menu Activation"
                            inputEvent:NpKeyboardM ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineInput instance ]
         inputActions ] removeInputAction:menuClickAction ];

    [[[ NPEngineInput instance ] 
         inputActions ] removeInputAction:menuActivationAction ];

    [ textures  removeAllObjects ];
    [ menuItems removeAllObjects ];

    DESTROY(textures);
    DESTROY(menuItems);

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
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
    return NO;
}

/*
- (BOOL) loadFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    if ( [ absolutePath isEqual:@"" ] == YES )
    {
        return NO;
    }

    NSDictionary * menu = [ NSDictionary dictionaryWithContentsOfFile:absolutePath ];

    NSString * effectString = [ menu objectForKey:@"Effect" ];
    NSString * fontString   = [ menu objectForKey:@"Font" ];
    NSDictionary * texturesDictionary = [ menu objectForKey:@"Textures" ];
    NSDictionary * items = [ menu objectForKey:@"Items" ];

    if ( effectString == nil )
    {
        NPLOG_ERROR(@"%@: Effect missing", name);
        return NO;
    }

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:effectString ];

    if ( fontString == nil )
    {
        NPLOG_ERROR(@"%@: Font missing", name);
        return NO;
    }

    font = [[[ NP Graphics ] fontManager ] loadFontFromPath:fontString ];

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

*/

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
            /*
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
            */
        }
    }
}

- (void) render
{
    if ( menuActive == YES )
    {
        [ menuItems makeObjectsPerformSelector:@selector(render) ];
    }
}

@end

