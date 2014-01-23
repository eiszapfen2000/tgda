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

    technique = [ menu colorTechnique ];
    color = [[ menu effect ] variableWithName:@"color" ];

    ASSERT_RETAIN(technique);
    ASSERT_RETAIN(color);

    return YES;
}

static bool sameSide(
    const FVector3 * const A,
    const FVector3 * const B,
    const FVector3 * const C,
    const FVector3 * const p
    )
{
    const FVector3 ab = fv3_vv_sub(B, A);
    const FVector3 ac = fv3_vv_sub(C, A);
    const FVector3 ap = fv3_vv_sub(p, A);

    const FVector3 c_ab_ac = fv3_vv_cross_product(&ab, &ac);
    const FVector3 c_ab_ap = fv3_vv_cross_product(&ab, &ap);

    return (fv3_vv_dot_product(&c_ab_ac, &c_ab_ap) >= 0) ? true : false;
}

- (void) onClick:(const FVector2)mousePosition
{
    const float geometryWidth  = frectangle_r_calculate_width(&alignedGeometry);
    const float geometryHeight = frectangle_r_calculate_height(&alignedGeometry);

    FVector3 topL, topR, topT, bottomL, bottomR, bottomB, mouse;

    topL.x = bottomL.x = alignedGeometry.min.x;
    topR.x = bottomR.x = alignedGeometry.max.x;

    topT.x = bottomB.x = alignedGeometry.min.x + floorf(geometryWidth / 2.0f);

    topL.y    = topR.y    = alignedGeometry.max.y - floorf(geometryHeight / 4.0f);
    bottomL.y = bottomR.y = alignedGeometry.min.y + floorf(geometryHeight / 4.0f);

    topT.y    = alignedGeometry.max.y;
    bottomB.y = alignedGeometry.min.y;

    topL.z = bottomL.z = 0.0f;
    topR.z = bottomR.z = 0.0f;
    topT.z = bottomB.z = 0.0f;

    mouse.x = mousePosition.x;
    mouse.y = mousePosition.y;
    mouse.z = 0.0f;

    const bool one   = sameSide(&topL, &topR, &topT, &mouse);
    const bool two   = sameSide(&topL, &topT, &topR, &mouse);
    const bool three = sameSide(&topT, &topR, &topL, &mouse);

    const bool four = sameSide(&bottomL, &bottomR, &bottomB, &mouse);
    const bool five = sameSide(&bottomL, &bottomB, &bottomR, &mouse);
    const bool six  = sameSide(&bottomB, &bottomR, &bottomL, &mouse);

    if ( one && two && three )
    {
        integerValue += integerStep;
        doubleValue += doubleStep;

        //NSLog(@"%ld %lf", integerValue, doubleValue);
    }

    if ( four && five && six )
    {
        integerValue -= integerStep;
        doubleValue -= doubleStep;

        //NSLog(@"%ld %lf", integerValue, doubleValue);
    }

    //NSLog(@"%ld", NSIntegerMin);

    integerValue = MIN(integerValue, maximumIntegerValue);
    integerValue = MAX(minimumIntegerValue, integerValue);

    doubleValue = MIN(doubleValue,  maximumDoubleValue);
    doubleValue = MAX(minimumDoubleValue, doubleValue);

    //NSLog(@"%ld %lf", integerValue, doubleValue);


//    NSLog(@"%f %f", bottomB.y, mouse.y);
//    NSLog(@"%d %d %d", (int32_t)one, (int32_t)two, (int32_t)three);
}

- (void) update:(const float)frameTime
{
    alignedGeometry
        = [ ODMenu alignRectangle:geometry withAlignment:alignment ];
}

- (void) render
{
    const FVector4 lineColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};
    const FVector4 quadColor = {1.0f, 1.0f, 1.0f, [ menu opacity ] * 0.25f};
    const FVector4 textColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};

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

