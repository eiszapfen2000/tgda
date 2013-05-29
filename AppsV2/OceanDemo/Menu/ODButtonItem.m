#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Font/NPFont.h"
#import "ODMenu.h"
#import "ODButtonItem.h"

@implementation ODButtonItem

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
    self = [ super initWithName:newName menu:newMenu ];

    active = NO;
    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &pixelCenterGeometry);

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(technique);
    SAFE_DESTROY(color);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)source
                      error:(NSError **)error
{
    BOOL result
        = [ super loadFromDictionary:source error:error ];

    if ( result == NO )
    {
        return NO;
    }

    NSString * l = [ source objectForKey:@"Label"];
    NSAssert(l != nil, @"");

    ASSIGNCOPY(label, l);

    if ( target != nil )
    {
        ODObjCGetVariable(target, offset, size, &active);
    }

    technique = RETAIN([ menu colorTechnique ]);
    color = RETAIN([[ menu effect ] variableWithName:@"color" ]);

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    active == YES ? (active = NO) : (active = YES);

    if ( target != nil )
    {
        ODObjCSetVariable(target, offset, size, &active);
    }
}

- (void) update:(const float)frameTime
{
    alignedGeometry
        = [ ODMenu alignRectangle:geometry withAlignment:alignment ];

    // move to pixel centers in order for the line to be
    // rasterised with 1 pixel thickness
    pixelCenterGeometry.min.x = alignedGeometry.min.x + 0.5f;
    pixelCenterGeometry.min.y = alignedGeometry.min.y + 0.5f;
    pixelCenterGeometry.max.x = alignedGeometry.max.x - 0.5f;
    pixelCenterGeometry.max.y = alignedGeometry.max.y - 0.5f;
}

- (void) render
{
    const FVector4 lineColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};
    const FVector4 quadColor = {1.0f, 1.0f, 1.0f, [ menu opacity ] * 0.25f};
    const FVector4 textColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};

    // draw quad if active
    if ( active == YES )
    {
        [ color setFValue:quadColor ];
        [ technique activate ];

        [ NPIMRendering renderFRectangle:alignedGeometry
                           primitiveType:NpPrimitiveQuads ];
    }

    // draw line
    [ color setFValue:lineColor ];
    [ technique activate ];

    [ NPIMRendering renderFRectangle:pixelCenterGeometry
                       primitiveType:NpPrimitiveLineLoop ];

    NPFont * font = [ menu fontForSize:textSize ];
    IVector2 textBounds = [ font boundsForString:label size:textSize ];

    const float geometryWidth = frectangle_r_calculate_width(&alignedGeometry);
    const float centering = (geometryWidth - textBounds.x) / 2.0f;

    IVector2 textPosition;
    textPosition.x = (int32_t)round(alignedGeometry.min.x + centering);
    textPosition.y = (int32_t)round(alignedGeometry.max.y);

    // draw text
    [ font renderString:label
              withColor:textColor
             atPosition:textPosition
                   size:textSize ];
}

@end
