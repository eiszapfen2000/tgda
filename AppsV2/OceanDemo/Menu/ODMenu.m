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
#import "Graphics/NPViewport.h"
#import "Graphics/NPEngineGraphics.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPMouse.h"
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
    fonts     = [[ NSMutableArray alloc ] init ];

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
    DESTROY(fonts);

    [ super dealloc ];
}

- (void) clear
{
    [ textures  removeAllObjects ];
    [ menuItems removeAllObjects ];
    [ fonts     removeAllObjects ];

    SAFE_DESTROY(effect);
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (NPFont *) fontAtIndex:(const NSUInteger)index
{
    return [ fonts objectAtIndex:index ];
}

- (NPFont *) fontForSize:(const uint32_t)size
{
    const NSUInteger numberOfFonts = [ fonts count ];
    assert(numberOfFonts != 0);

    int32_t sizes[numberOfFonts];
    memset(sizes, 0, sizeof(int32_t) * numberOfFonts);

    for ( NSUInteger i = 0; i < numberOfFonts; i++ )
    {
        NPFont * font = [ fonts objectAtIndex:i ];
        sizes[i] = abs([ font renderedSize ]);
    }

    NSUInteger minIndex = ULONG_MAX;
    int32_t minDelta = INT_MAX;
    for ( NSUInteger i = 0; i < numberOfFonts; i++ )
    {
        const int32_t deltaSize = abs(((int32_t)size) - sizes[i]);

        if ( deltaSize < minDelta )
        {
            minDelta = deltaSize;
            minIndex = i;
        }
    }

    return [ fonts objectAtIndex:minIndex ];
}

- (NPEffect *) effect
{
    return effect;
}

- (NPEffectTechnique *) colorTechnique
{
    NSAssert(effect != nil, @"");

    return [ effect techniqueWithName:@"color" ];
}

- (NPEffectTechnique *) textureTechnique
{
    NSAssert(effect != nil, @"");

    return [ effect techniqueWithName:@"texture" ];
}

- (NPEffectTechnique *) fontTechnique
{
    NSAssert(effect != nil, @"");

    return [ effect techniqueWithName:@"font" ];
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
    NSArray  * fontFileNames   = [ menu objectForKey:@"Fonts"  ];
    NSDictionary * itemSources = [ menu objectForKey:@"Items"  ];

    NSAssert((effectString != nil) && (fontFileNames != nil)
             && (itemSources != nil), @"");

    effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:effectString ];

    ASSERT_RETAIN(effect);

    NSAssert([ effect techniqueWithName:@"color" ]   != nil, @"");
    NSAssert([ effect techniqueWithName:@"texture" ] != nil, @"");
    NSAssert([ effect techniqueWithName:@"font" ]    != nil, @"");

    NPEffectTechnique * fontTechnique = [ self fontTechnique ];
    const NSUInteger numberOfFontFileNames = [ fontFileNames count ];
    for ( NSUInteger i = 0; i < numberOfFontFileNames; i++ )
    {
        NSString * fontFileName = [ fontFileNames objectAtIndex:i ];

        NPFont * font = [[ NPFont alloc ] init ];
        if ( [ font loadFromFile:fontFileName
                       arguments:nil
                           error:error ] == YES )
        {
            [ fonts addObject:font ];
            [ font setEffectTechnique:fontTechnique ];
        }

        DESTROY(font);
    }

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
            const int32_t mouseX = [[[ NPEngineInput instance ] mouse ] x ];
            const int32_t mouseY = [[[ NPEngineInput instance ] mouse ] y ];

            const uint32_t widgetHeight
                = [[[ NPEngineGraphics instance ] viewport ] widgetHeight ];

            const FVector2 clickPosition = {mouseX, widgetHeight - mouseY};

            const NSUInteger numberOfMenuItems = [ menuItems count ];
            for ( NSUInteger i = 0; i < numberOfMenuItems; i++ )
            {
                id menuItem = [ menuItems objectAtIndex:i ];
                if ( [ menuItem isHit:clickPosition ] == YES )
                {
                    [ menuItem onClick:clickPosition ];
                    break;
                }
            }
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

