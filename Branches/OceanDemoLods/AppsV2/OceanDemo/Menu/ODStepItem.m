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
    stepInteger = 1;

    minimumDoubleValue = -DBL_MAX;
    maximumDoubleValue =  DBL_MAX;
    stepDouble = 1.0;

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

    FRectangle pixelCenterGeometry = alignedGeometry;
    pixelCenterGeometry.min.x += 0.5f;
    pixelCenterGeometry.min.y += 0.5f;
    pixelCenterGeometry.max.x -= 0.5f;
    pixelCenterGeometry.max.y -= 0.5f;

    // draw line
    [ color setFValue:lineColor ];
    [ technique activate ];

    [ NPIMRendering renderFRectangle:pixelCenterGeometry
                       primitiveType:NpPrimitiveLineLoop ];
}

@end

