#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODMenu.h"
#import "ODTextureItem.h"

@implementation ODTextureItem

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

    frectangle_rssss_init_with_min_max(&pixelCenterGeometry, 0.0f, 0.0f, 0.0f, 0.0f);
    channels = (FVector4){1.0f, 1.0f, 1.0f, 1.0f};

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(colorTechnique);
    SAFE_DESTROY(textureRangeTechnique);
    SAFE_DESTROY(color);
    SAFE_DESTROY(range);
    SAFE_DESTROY(mask);
    SAFE_DESTROY(texture);

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
    NSString * t = [ source objectForKey:@"Texture" ];

    NSAssert(l != nil, @"Label missing");
    NSAssert(t != nil, @"Texture name missing");

    ASSIGNCOPY(label, l);

    NSArray * channelStrings = [ source objectForKey:@"Channels"];
    if ( channelStrings != nil )
    {
        NSUInteger numberOfStrings = [ channelStrings count ];
        NSAssert(numberOfStrings == 4, @"");

        channels.x = ([[ channelStrings objectAtIndex:0 ] boolValue ] == YES) ? 1.0f : 0.0f;
        channels.y = ([[ channelStrings objectAtIndex:1 ] boolValue ] == YES) ? 1.0f : 0.0f;
        channels.z = ([[ channelStrings objectAtIndex:2 ] boolValue ] == YES) ? 1.0f : 0.0f;
        channels.w = ([[ channelStrings objectAtIndex:3 ] boolValue ] == YES) ? 1.0f : 0.0f;
    }

    colorTechnique        = [ menu colorTechnique ];
    textureRangeTechnique = [ menu textureRangeTechnique ];

    ASSERT_RETAIN(colorTechnique);
    ASSERT_RETAIN(textureRangeTechnique);

    color = [[ menu effect ] variableWithName:@"color" ];
    range = [[ menu effect ] variableWithName:@"range" ];
    mask  = [[ menu effect ] variableWithName:@"mask"  ];

    ASSERT_RETAIN(color);
    ASSERT_RETAIN(range);
    ASSERT_RETAIN(mask);

    texture
        = [[[ NPEngineGraphics instance ] textures2D ] getAssetWithName:t ];

    ASSERT_RETAIN(texture);

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    /*
    active == YES ? (active = NO) : (active = YES);

    if ( target != nil )
    {
        ODObjCSetVariable(target, offset, size, &active);
    }
    */
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
    const FRectangle texcoords = {{0.0f, 0.0f}, {1.0f, 1.0f}};
    FVector2 valueRange = {.x = 0.0f, .y = 1.0f};

    if ( target != nil )
    {
        ODObjCGetVariable(target, offset, size, &valueRange);
    }

    //NSLog(@"%@ %f %f", label, valueRange.x, valueRange.y);

    [[[ NPEngineGraphics instance ] textureBindingState ] setTexture:texture texelUnit:0 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

    [ range setFValue:valueRange ];
    [ mask  setFValue:channels   ];
    [ textureRangeTechnique activate ];
    [ NPIMRendering renderFRectangle:alignedGeometry
                           texCoords:texcoords
                       primitiveType:NpPrimitiveQuads ];

    // draw line
    [ color setFValue:lineColor ];
    [ colorTechnique activate ];

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

