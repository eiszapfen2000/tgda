#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Container/NSArray+NPPPersistentObject.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
#import "ODMenuItem.h"
#import "ODCheckboxItem.h"
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
    menuActive = YES;

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
    [ self clear ];

    [[[ NPEngineInput instance ]
         inputActions ] removeInputAction:menuClickAction ];

    [[[ NPEngineInput instance ] 
         inputActions ] removeInputAction:menuActivationAction ];

    DESTROY(textures);
    DESTROY(menuItems);

    [ super dealloc ];
}

- (void) clear
{
    [ textures  removeAllObjects ];
    [ menuItems removeAllObjects ];

    SAFE_DESTROY(effect);
    SAFE_DESTROY(font);
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (NPFont *) font
{
    return font;
}

- (NPEffect *) effect
{
    return effect;
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

    NPLOG(@"");
    NPLOG(@"Loading menu \"%@\"", completeFileName);

    NSDictionary * menu 
        = [ NSDictionary dictionaryWithContentsOfFile:completeFileName ];

    NSAssert(menu != nil, @"");

    NSString * effectString    = [ menu objectForKey:@"Effect" ];
    NSString * fontString      = [ menu objectForKey:@"Font"   ];
    NSDictionary * itemSources = [ menu objectForKey:@"Items"  ];

    NSAssert((effectString != nil) && (fontString != nil)
             && (itemSources != nil), @"");

    effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:effectString ];

    ASSERT_RETAIN(effect);

    font = [[ NPFont alloc ] init ];
    BOOL fontResult
        = [ font loadFromFile:fontString
                    arguments:nil
                        error:error ];

    NSAssert(fontResult == YES, @"");

    NSString * key;
    Class itemClass;
    NSString * itemType;
    NSDictionary * itemSource;
    NSEnumerator * keyEnumerator = [ itemSources keyEnumerator ];

    while (( key = [ keyEnumerator nextObject ] ))
    {
        itemSource = [ itemSources objectForKey:key ];
        itemType   = [ itemSource  objectForKey:@"Type" ];

        itemClass = NSClassFromString(itemType);
        NSAssert1(itemClass != Nil, @"Invalid Class Name %@", itemType);

        id item = [[ itemClass alloc ] initWithName:key menu:self ];

        if ( [ item loadFromDictionary:itemSource error:error ] == YES )
        {
            [ menuItems addObject:item ];
        }

        DESTROY(item);
    }

    return YES;
}

- (BOOL) isHit:(const FVector2)mousePosition
{
    BOOL result = NO;

    const NSUInteger numberOfMenuItems = [ menuItems count ];
    for ( NSUInteger i = 0; i < numberOfMenuItems; i++ )
    {
        id menuItem = [ menuItems objectAtIndex:i ];
        if ( [ menuItem isHit:mousePosition ] == YES )
        {
            result = YES;
            break;
        }
    }

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    const NSUInteger numberOfMenuItems = [ menuItems count ];
    for ( NSUInteger i = 0; i < numberOfMenuItems; i++ )
    {
        id menuItem = [ menuItems objectAtIndex:i ];
        if ( [ menuItem isHit:mousePosition ] == YES )
        {
            [ menuItem onClick:mousePosition ];
        }
    }
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

        }
    }

    const NSUInteger numberOfMenuItems = [ menuItems count ];
    for ( NSUInteger i = 0; i < numberOfMenuItems; i++ )
    {
        [[ menuItems objectAtIndex:i ] update:frameTime ];
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

