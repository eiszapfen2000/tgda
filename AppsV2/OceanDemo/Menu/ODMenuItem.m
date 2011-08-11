#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Graphics/NPEngineGraphicsEnums.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "ODMenu.h"
#import "ODMenuItem.h"

@implementation ODMenuItem

- (id) init
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
{
    [ self notImplemented:_cmd ];
    return nil;
}

- (id) initWithName:(NSString *)newName
               menu:(ODMenu *)newMenu
{
    self = [ super initWithName:newName ];

    NSAssert(newMenu != nil, @"");

    menu = newMenu;
    alignment = NpOrthographicAlignUnknown;
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &geometry);
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &alignedGeometry);
    textSize = 0;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    NSArray * positionStrings  = [ source objectForKey:@"Position"  ];
    NSArray * sizeStrings      = [ source objectForKey:@"Size"      ];
    NSString * alignmentString = [ source objectForKey:@"Alignment" ];

    NSAssert(positionStrings != nil && sizeStrings != nil
             && alignmentString != nil, @"");

    // alignment
    alignment
        = [ alignmentString
                orthographicAlignmentValueWithDefault:NpOrthographicAlignUnknown ];
    
    // position and size
    FVector2 position, checkBoxSize;
    position.x = [[ positionStrings objectAtIndex:0 ] intValue ];
    position.y = [[ positionStrings objectAtIndex:1 ] intValue ];
    checkBoxSize.x = [[ sizeStrings objectAtIndex:0 ] intValue ];
    checkBoxSize.y = [[ sizeStrings objectAtIndex:1 ] intValue ];
    frectangle_vv_init_with_min_and_size_r(&position, &checkBoxSize, &geometry);

    return YES;
}

- (BOOL) isHit:(const FVector2)mousePosition
{
    return frectangle_vr_is_point_inside(&mousePosition, &alignedGeometry);
}

- (void) onClick:(const FVector2)mousePosition
{
    [ self subclassResponsibility:_cmd ];
}

- (void) update:(const float)frameTime
{
    [ self subclassResponsibility:_cmd ];
}

- (void) render
{
    [ self subclassResponsibility:_cmd ];
}


@end
