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
#import "ODSliderItem.h"

@interface ODSliderItem (Private)

- (float) scaledValue;

@end

@implementation ODSliderItem (Private)

- (float) scaledValue
{
    float normalisedScale = 0.0f;

    switch ( direction )
    {
        case OdHorizontalSliderItem:
        {
            const float lineWidth
                = frectangle_r_calculate_width(&lineGeometry);

            const float headCenter
                = geometry.min.x + headOffset.x + (headSize.x * 0.5f);

            normalisedScale
                = (headCenter - lineGeometry.min.x) / lineWidth;

            break;
        }

        case OdVerticalSliderItem:
        {
            const float lineHeight
                = frectangle_r_calculate_height(&lineGeometry);

            const float headCenter
                = geometry.min.y + headOffset.y + (headSize.y * 0.5f);

            normalisedScale
                = (headCenter - lineGeometry.min.y) / lineHeight;

            break;
        }
    }

    return normalisedScale * ( maximumValue - minimumValue ) + minimumValue;
}

@end

@implementation ODSliderItem

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

    lineSize.x = lineSize.y = 0.0f;
    headSize.x = headSize.y = 0.0f;
    headOffset.x = headOffset.y = 0.0f;
    frectangle_rssss_init_with_min_max(&lineGeometry, 0.0f, 0.0f, 0.0f, 0.0f);
    frectangle_rssss_init_with_min_max(&alignedHeadGeometry, 0.0f, 0.0f, 0.0f, 0.0f);
    frectangle_rssss_init_with_min_max(&alignedLineGeometry, 0.0f, 0.0f, 0.0f, 0.0f);

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(technique);
    SAFE_DESTROY(color);
    SAFE_DESTROY(label);

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
    NSString * minimumValueString = [ source objectForKey:@"MinimumValue" ];
    NSString * maximumValueString = [ source objectForKey:@"MaximumValue" ];
    NSArray * headSizeStrings = [ source objectForKey:@"HeadSize" ];
    NSArray * lineSizeStrings = [ source objectForKey:@"LineSize" ];

    NSAssert(l != nil && minimumValueString != nil && maximumValueString != nil
             && headSizeStrings != nil && lineSizeStrings != nil, @"");

    ASSIGNCOPY(label, l);

    headSize.x = [[ headSizeStrings objectAtIndex:0 ] intValue ];
    headSize.y = [[ headSizeStrings objectAtIndex:1 ] intValue ];
    lineSize.x = [[ lineSizeStrings objectAtIndex:0 ] intValue ];
    lineSize.y = [[ lineSizeStrings objectAtIndex:1 ] intValue ];

    minimumValue = [ minimumValueString floatValue ];
    maximumValue = [ maximumValueString floatValue ];

    if (headSize.y > headSize.x)
    {
        direction = OdHorizontalSliderItem;
    }
    else
    {
        direction = OdVerticalSliderItem;
    }
    
    FVector2 geometrySize;
    FVector2 geometryPos = geometry.min;
    geometrySize.x = MAX(headSize.x, lineSize.x);
    geometrySize.y = MAX(headSize.y, lineSize.y);
    frectangle_rvv_init_with_min_and_size(&geometry, &geometryPos, &geometrySize);

    FVector2 linePosition = geometryPos;

    switch ( direction )
    {
        case OdHorizontalSliderItem:
        {
            linePosition.y += (headSize.y * 0.5f);
            linePosition.y -= (lineSize.y * 0.5f);
            break;
        }

        case OdVerticalSliderItem:
        {
            linePosition.x += (headSize.x * 0.5f);
            linePosition.x -= (lineSize.x * 0.5f);
            break;
        }
    }

    frectangle_rvv_init_with_min_and_size(&lineGeometry, &linePosition, &lineSize);

    if ( targetProperty.target != nil )
    {
        double currentValue;
        double normalisedValue;

        ODObjCGetVariable(targetProperty.target,
            targetProperty.offset,
            targetProperty.size,
            &currentValue);

        normalisedValue = (currentValue - minimumValue) / (maximumValue - minimumValue);

        switch ( direction )
        {
            case OdHorizontalSliderItem:
            {
                const float halfHeadWidth = (headSize.x) * 0.5f;
                headOffset.x -= halfHeadWidth;
                headOffset.x += (lineSize.x * normalisedValue);
                break;
            }

            case OdVerticalSliderItem:
            {
                const float halfHeadHeight = (headSize.y) * 0.5f;
                headOffset.y -= halfHeadHeight;
                headOffset.y += (lineSize.y * normalisedValue);
                break;
            }
        }
    }

    technique = RETAIN([ menu colorTechnique ]);
    color = RETAIN([[ menu effect ] variableWithName:@"color" ]);

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    const float deltaX = mousePosition.x - alignedGeometry.min.x;
    const float deltaY = mousePosition.y - alignedGeometry.min.y;

    switch ( direction )
    {
        case OdHorizontalSliderItem:
        {
            headOffset.x = (headSize.x * -0.5f) + deltaX;
            break;
        }

        case OdVerticalSliderItem:
        {
            headOffset.y = (headSize.y * -0.5f) + deltaY;
            break;
        }
    }

    if ( targetProperty.target != nil )
    {
        const double scaledValue = [ self scaledValue ];

        ODObjCSetVariable(targetProperty.target,
            targetProperty.offset,
            targetProperty.size,
            &scaledValue);
    }
}

- (void) update:(const float)frameTime
{
    alignedGeometry
        = [ ODMenu alignRectangle:geometry withAlignment:alignment ];

    alignedLineGeometry
        = [ ODMenu alignRectangle:lineGeometry withAlignment:alignment ];

    FVector2 headPosition = alignedGeometry.min;
    headPosition.x += headOffset.x;
    headPosition.y += headOffset.y;

    frectangle_rvv_init_with_min_and_size(&alignedHeadGeometry, &headPosition, &headSize);
}

- (void) render
{
    const FVector4 lineColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};
    const FVector4 quadColor = {1.0f, 1.0f, 1.0f, [ menu opacity ] * 0.25f};

    [ color setFValue:quadColor ];
    [ technique activate ];

    [ NPIMRendering renderFRectangle:alignedGeometry
                       primitiveType:NpPrimitiveQuads ];


    [ color setFValue:lineColor ];
    [ technique activate ];

    [ NPIMRendering renderFRectangle:alignedLineGeometry
                       primitiveType:NpPrimitiveQuads ];

    [ NPIMRendering renderFRectangle:alignedHeadGeometry
                       primitiveType:NpPrimitiveQuads ];
}

@end
