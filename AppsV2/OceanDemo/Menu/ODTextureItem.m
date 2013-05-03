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

    frectangle_ssss_init_with_min_max_r(0.0f, 0.0f, 0.0f, 0.0f, &pixelCenterGeometry);

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(colorTechnique);
    SAFE_DESTROY(textureTechnique);
    SAFE_DESTROY(color);
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

    colorTechnique   = RETAIN([ menu colorTechnique   ]);
    textureTechnique = RETAIN([ menu textureTechnique ]);
    color = RETAIN([[ menu effect ] variableWithName:@"color" ]);

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

    [[[ NPEngineGraphics instance ] textureBindingState ] setTexture:texture texelUnit:0 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

    [ textureTechnique activate ];
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

    const float geometryWidth = frectangle_r_calculate_width(&geometry);
    const float centering = (geometryWidth - textBounds.x) / 2.0f;

    IVector2 textPosition;
    textPosition.x = (int32_t)round(geometry.min.x + centering);
    textPosition.y = (int32_t)round(geometry.max.y);

    // draw text
    [ font renderString:label
              withColor:textColor
             atPosition:textPosition
                   size:textSize ];
}

@end

