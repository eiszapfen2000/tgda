#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
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

    return self;
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

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    active == YES ? (active = NO) : (active = YES);

    if ( target != nil )
    {
        GSObjCSetVariable(target, offset, size, &active);
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

    round(0.5f);
}

- (void) render
{
    FVector4 c = {1.0f, 1.0f, 1.0f, 1.0f};

    NPEffect * effect = [ menu effect ];
    NPEffectTechnique * technique = [ effect techniqueWithName:@"color" ];
    NPEffectVariableFloat4 * color = [ effect variableWithName:@"color" ];
    [ color setValue:c ];
    [ technique activate ];

    glBegin(GL_LINE_LOOP);
        glVertex2f(pixelCenterGeometry.min.x, pixelCenterGeometry.min.y);
        glVertex2f(pixelCenterGeometry.max.x, pixelCenterGeometry.min.y);
        glVertex2f(pixelCenterGeometry.max.x, pixelCenterGeometry.max.y);
        glVertex2f(pixelCenterGeometry.min.x, pixelCenterGeometry.max.y);
    glEnd();

    if ( active == YES )
    {
        c.w = 0.25f;
        [ color setValue:c ];
        [ technique activate ];

        glBegin(GL_QUADS);
            glVertex2f(pixelCenterGeometry.min.x, pixelCenterGeometry.min.y);
            glVertex2f(pixelCenterGeometry.max.x, pixelCenterGeometry.min.y);
            glVertex2f(pixelCenterGeometry.max.x, pixelCenterGeometry.max.y);
            glVertex2f(pixelCenterGeometry.min.x, pixelCenterGeometry.max.y);
        glEnd();
    }

    NPFont * font = [ menu fontForSize:textSize ];
    IVector2 textBounds = [ font boundsForString:label size:textSize ];

    const float geometryWidth = frectangle_r_calculate_width(&geometry);
    const float centering = (geometryWidth - textBounds.x) / 2.0f;

    IVector2 textPosition;
    textPosition.x = (int32_t)round(geometry.min.x + centering);
    textPosition.y = (int32_t)round(geometry.max.y);

    FVector3 tC = {1.0f, 1.0f, 1.0f};

    [ font renderString:label withColor:tC atPosition:textPosition size:textSize ];
}

@end
