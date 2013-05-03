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
    fm4_m_set_identity(&translation);
    v2_v_init_with_zeros(&windDirection);

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

        //printf("%u %f %f %f\n", i, angle, x * radius, y * radius);
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
                setVertexStream:vertexBuffer
                     atLocation:NpVertexStreamPositions
                          error:NULL ];

    NSAssert(result, @"BROKEN");

    DESTROY(vertexBuffer);

    return result;
}

- (void) onClick:(const FVector2)mousePosition
{
    FVector2 center2D;
    frectangle_r_calculate_center_v(&alignedGeometry, &center2D);

    windDirection.x = mousePosition.x - center2D.x;
    windDirection.y = mousePosition.y - center2D.y;
    v2_v_normalise(&windDirection);

    // set target property
    if ( target != nil )
    {
        ODObjCSetVariable(target, offset, size, &windDirection);
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

    // generate translation matrix
    FVector2 center2D;
    FVector3 center3D;

    frectangle_r_calculate_center_v(&alignedGeometry, &center2D);
    center3D = (FVector3){center2D.x, center2D.y, 0.0f};
    fm4_mv_translation_matrix(&translation, &center3D);

    // get value from target
    if ( target != nil )
    {
        ODObjCGetVariable(target, offset, size, &windDirection);
    }
}

- (void) render
{
    const FVector4 lineColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};
    const FVector4 quadColor = {1.0f, 1.0f, 1.0f, [ menu opacity ] * 0.25f};
    const FVector4 textColor = {1.0f, 1.0f, 1.0f, [ menu opacity ]};

    NPTransformationState * tState
        = [[ NPEngineCore instance ] transformationState ];

    FMatrix4 modelMatrix = *[ tState modelMatrix ];

    [ tState setFModelMatrix:&translation ];

    [ color setFValue:quadColor ];
    [ technique activate ];
    [ circleGeometry renderWithPrimitiveType:NpPrimitiveTriangleFan ];

    [ color setFValue:lineColor ];
    [ technique activate ];
    [ circleGeometry renderWithPrimitiveType:NpPrimitiveLineStrip firstIndex:1 lastIndex:25 ];

    [ tState setFModelMatrix:&modelMatrix ];
}

@end
