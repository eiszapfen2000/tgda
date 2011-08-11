#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import "ODMenuItem.h"

@implementation ODMenuItem

- (id) init
{
    return [ self initWithName:@"Menu Item" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    menu = nil;
    alignment = NpOrthographicAlignUnknown;
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &geometry);
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

    return NO;
}

- (BOOL) isHit:(const FVector2)mousePosition
{
    [ self subclassResponsibility:_cmd ];

    return NO;
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
