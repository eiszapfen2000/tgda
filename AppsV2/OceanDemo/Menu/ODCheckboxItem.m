#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "ODMenu.h"
#import "ODCheckboxItem.h"

@implementation ODCheckboxItem

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

    checked = NO;

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

    if ( target != nil )
    {
        ODObjCSetVariable(target, offset, size, &checked);
    }

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    checked == YES ? (checked = NO) : (checked = YES);

    /*
    if ( target != nil )
    {
        GSObjCSetVariable(target, offset, size, &checked);
    }
    */

    NSLog(@"%d", (int32_t)checked);
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
    const FVector4 c = {1.0f, 1.0f, 1.0f, [ menu opacity ]};

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
}

@end
