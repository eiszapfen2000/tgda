#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/NPObject/NPObjectManager.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Font/NPFont.h"
#import "ODMenu.h"
#import "ODWindDirectionItem.h"

@implementation ODWindDirectionItem

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

    circleGeometry = [[ NPVertexArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(circleGeometry);
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

    /*
    if ( target != nil )
    {
        ODObjCGetVariable(target, offset, size, &active);
    }
    */

    technique = RETAIN([ menu colorTechnique ]);
    color = RETAIN([[ menu effect ] variableWithName:@"color" ]);

    const float itemWidth  = frectangle_r_calculate_width(&geometry);
    const float itemHeight = frectangle_r_calculate_height(&geometry);

    const float halfWidth  = itemWidth  / 2.0f;
    const float halfHeight = itemHeight / 2.0f;
    const float radius = MIN(halfWidth, halfHeight);

    const uint32_t numberOfTriangles = 24;
    const NSUInteger numberOfVertices = numberOfTriangles + 2;
    const NSUInteger numberOfBytes = sizeof(FVector2) * numberOfVertices;
    const double delta = MATH_2_MUL_PI / (double)numberOfTriangles;

    NSMutableData * geometryData
        = [ NSMutableData dataWithLength:numberOfBytes ];

    FVector2 * vertices = [ geometryData mutableBytes ];
    vertices[0].x = vertices[0].y = 0.0f;

    for (uint32_t i = 0; i < numberOfTriangles + 1; i++)
    {
        const double angle = (double)i * delta;

        const float x = cos(angle);
        const float y = sin(angle);

        vertices[i + 1].x = x * radius;
        vertices[i + 1].y = y * radius;

        printf("%u %f %f %f\n", i, angle, x * radius, y * radius);
    }

    NPBufferObject * vertexBuffer = [[ NPBufferObject alloc ] init ];

    result
        = [ vertexBuffer
                generateStaticGeometryBuffer:NpBufferDataFormatFloat32
                                  components:2
                                        data:geometryData
                                  dataLength:numberOfBytes
                                       error:NULL ];

    NSAssert(result, @"BROKEN");

    result
        = [ circleGeometry
                addVertexStream:vertexBuffer
                     atLocation:NpVertexStreamPositions
                          error:NULL ];

    NSAssert(result, @"BROKEN");

    DESTROY(vertexBuffer);

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    NSLog(@"OUCH");
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

    // draw quad
    /*
    [ NPIMRendering renderFRectangle:pixelCenterGeometry
                       primitiveType:NpPrimitiveQuads ];
    */


    FVector2 center;
    frectangle_r_calculate_center_v(&alignedGeometry, &center);

    FVector3 t = {center.x, center.y, 0.0f};
    FMatrix4 translation = fm4_v_translation_matrix(&t);

    NPTransformationState * tState
        = [[ NPEngineCore instance ] transformationState ];

    FMatrix4 modelMatrix = *[ tState modelMatrix ];

    [ tState setModelMatrix:&translation ];

    [ color setValue:quadColor ];
    [ technique activate ];

    /*
    [ NPIMRendering renderFRectangle:pixelCenterGeometry
                       primitiveType:NpPrimitiveLineLoop ];
    */

    [ circleGeometry renderWithPrimitiveType:NpPrimitiveTriangleFan ];

    [ color setValue:lineColor ];
    [ technique activate ];


    [ circleGeometry renderWithPrimitiveType:NpPrimitiveLineStrip firstIndex:1 lastIndex:25 ];

    [ tState setModelMatrix:&modelMatrix ];
}

@end
