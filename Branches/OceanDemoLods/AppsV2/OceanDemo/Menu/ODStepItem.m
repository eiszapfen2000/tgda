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
#import "ODStepItem.h"

@implementation ODStepItem

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

    mode = OdStepItemUnknownMode;

    minimumIntegerValue = NSIntegerMin;
    maximumIntegerValue = NSIntegerMax;
    integerStep = 1;
    integerValue = 0;

    minimumDoubleValue = -DBL_MAX;
    maximumDoubleValue =  DBL_MAX;
    doubleStep = 1.0;
    doubleValue = 0.0;

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
    NSAssert(l != nil, @"");

    ASSIGNCOPY(label, l);

    NSString * modeString = [ source objectForKey:@"Mode" ];
    NSString * minimumValueString = [ source objectForKey:@"MinimumValue" ];
    NSString * maximumValueString = [ source objectForKey:@"MaximumValue" ];
    NSString * stepString = [ source objectForKey:@"Step" ];

    NSAssert1(modeString != nil && minimumValueString != nil
              && maximumValueString != nil && stepString != nil,
              @"Item \"%@\" does not contain all necessary elements", name);

    if ( [[ modeString lowercaseString ] isEqual:@"integer" ])
    {
        mode = OdStepItemIntegerMode;
    }

    if ( [[ modeString lowercaseString ] isEqual:@"float" ])
    {
        mode = OdStepItemFloatMode;
    }

    NSAssert2(mode != OdStepItemUnknownMode, @"Item \"%@\": Unrecognized mode \"%@\"", name, modeString);

    switch ( mode )
    {
        case OdStepItemIntegerMode:
        {
            minimumIntegerValue = [ minimumValueString integerValue ];
            maximumIntegerValue = [ maximumValueString integerValue ];
            integerStep = [ stepString integerValue ];
            break;
        }
        case OdStepItemFloatMode:
        {
            minimumDoubleValue = [ minimumValueString doubleValue ];
            maximumDoubleValue = [ maximumValueString doubleValue ];
            doubleStep = [ stepString doubleValue ];
            break;
        }
        default:
            break;
    }

    integerValue = minimumIntegerValue;
    doubleValue  = minimumDoubleValue;

    technique = [ menu colorTechnique ];
    color = [[ menu effect ] variableWithName:@"color" ];

    ASSERT_RETAIN(technique);
    ASSERT_RETAIN(color);

    return YES;
}

- (void) onClick:(const FVector2)mousePosition
{
    const float geometryWidth  = frectangle_r_calculate_width(&alignedGeometry);
    const float geometryHeight = frectangle_r_calculate_height(&alignedGeometry);

    FRectangle top = alignedGeometry;
    FRectangle bottom = alignedGeometry;

    top.min.y    = alignedGeometry.max.y - ceilf(geometryHeight / 4.0f) - 2.0f;
    top.max.y    = top.max.y + 2.0f;
    bottom.max.y = alignedGeometry.min.y + ceilf(geometryHeight / 4.0f) + 2.0f;
    bottom.min.y = bottom.min.y - 4.0f;

    const int32_t insideTop    = frectangle_vr_is_point_inside(&mousePosition, &top);
    const int32_t insideBottom = frectangle_vr_is_point_inside(&mousePosition, &bottom);

    if (insideTop)
    {
        integerValue += integerStep;
        doubleValue += doubleStep;
    }

    if ( insideBottom)
    {
        integerValue -= integerStep;
        doubleValue -= doubleStep;
    }

    integerValue = MIN(integerValue, maximumIntegerValue);
    integerValue = MAX(minimumIntegerValue, integerValue);

    doubleValue = MIN(doubleValue,  maximumDoubleValue);
    doubleValue = MAX(minimumDoubleValue, doubleValue);

    if ( target != nil )
    {
        switch ( mode )
        {
            case OdStepItemIntegerMode:
            {
                ODObjCSetVariable(target, offset, size, &integerValue);
                break;
            }
            case OdStepItemFloatMode:
            {
                ODObjCSetVariable(target, offset, size, &doubleValue);
                break;
            }
            default:
                break;
        }        
    }
}

- (void) update:(const float)frameTime
{
    alignedGeometry
        = [ ODMenu alignRectangle:geometry withAlignment:alignment ];

    // get value from target
    if ( target != nil )
    {

        switch ( mode )
        {
            case OdStepItemIntegerMode:
            {
                ODObjCGetVariable(target, offset, size, &integerValue);
                break;
            }
            case OdStepItemFloatMode:
            {
                ODObjCGetVariable(target, offset, size, &doubleValue);
                break;
            }
            default:
                break;
        }        
    }
}

- (void) render
{
    const FVector4 lineColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};
    const FVector4 quadColor = {1.0f, 1.0f, 1.0f, [ menu opacity ] * 0.25f};
    const FVector4 textColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};

    FRectangle pixelCenterGeometry = alignedGeometry;
    // move to pixel centers in order for the line to be
    // rasterised with 1 pixel thickness
    pixelCenterGeometry.min.x = alignedGeometry.min.x + 0.5f;
    pixelCenterGeometry.min.y = alignedGeometry.min.y + 0.5f;
    pixelCenterGeometry.max.x = alignedGeometry.max.x - 0.5f;
    pixelCenterGeometry.max.y = alignedGeometry.max.y - 0.5f;

    // draw line
    [ color setFValue:lineColor ];
    [ technique activate ];

    const float width  = alignedGeometry.max.x - alignedGeometry.min.x;
    const float height = alignedGeometry.max.y - alignedGeometry.min.y;

    glBegin(GL_TRIANGLES);
        // top triangle
        glVertex2f(alignedGeometry.min.x, alignedGeometry.max.y - floorf(height / 4.0f));
        glVertex2f(alignedGeometry.max.x, alignedGeometry.max.y - floorf(height / 4.0f));
        glVertex2f(alignedGeometry.min.x + floorf(width / 2.0f), alignedGeometry.max.y);
        // bottom triangle
        glVertex2f(alignedGeometry.min.x, alignedGeometry.min.y + floorf(height / 4.0f));
        glVertex2f(alignedGeometry.max.x, alignedGeometry.min.y + floorf(height / 4.0f));
        glVertex2f(alignedGeometry.min.x + floorf(width / 2.0f), alignedGeometry.min.y);
    glEnd();

    [ NPIMRendering renderFRectangle:pixelCenterGeometry
                       primitiveType:NpPrimitiveLineLoop ];

    NSString * renderString = [ NSString stringWithFormat:@"%ld", integerValue ];

    NPFont * font = [ menu fontForSize:textSize ];
    IVector2 textBounds = [ font boundsForString:renderString size:textSize ];

    const float geometryWidth  = frectangle_r_calculate_width(&alignedGeometry);
    const float geometryHeight = frectangle_r_calculate_height(&alignedGeometry);

    const float centering = (geometryWidth - textBounds.x) / 2.0f;

    IVector2 textPosition;
    textPosition.x = (int32_t)round(alignedGeometry.min.x + centering);
    textPosition.y = (int32_t)round(alignedGeometry.max.y - (geometryHeight / 4.0f));

    // draw text
    [ font renderString:renderString
              withColor:textColor
             atPosition:textPosition
                   size:textSize ];

}

@end

