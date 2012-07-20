#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODBasePlane.h"

static FVector3 computeBasePlanePosition(const Matrix4 * const inverseViewProjection,
                                         Plane basePlane,
                                         Vector2 postProjectionVertex)
{
    const Vector4 nearPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, -1.0, 1.0};

    const Vector4 farPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, 1.0, 1.0};

    const Vector4 resultN = m4_mv_multiply(inverseViewProjection, &nearPlaneVertex);
    const Vector4 resultF = m4_mv_multiply(inverseViewProjection, &farPlaneVertex);

    Ray ray;
    ray.point.x = resultN.x / resultN.w;
    ray.point.y = resultN.y / resultN.w;
    ray.point.z = resultN.z / resultN.w;

    ray.direction.x = (resultF.x / resultF.w) - ray.point.x;
    ray.direction.y = (resultF.y / resultF.w) - ray.point.y;
    ray.direction.z = (resultF.z / resultF.w) - ray.point.z;

    Vector3 intersection;
    int32_t r = plane_pr_intersect_with_ray_v(&basePlane, &ray, &intersection);

    FVector3 result;
    result.x = intersection.x;
    result.y = intersection.y;
    result.z = intersection.z;

    return result;
}

@implementation ODBasePlane

- (id) init
{
	return [ self initWithName:@"ODBasePlane" ];
}

- (id) initWithName:(NSString *)newName;
{
	self = [ super initWithName:newName ];

    // y = 0 plane
    plane_pssss_init_with_components(&basePlane, 0.0, 1.0, 0.0, 0.0);

    cornerVertices = ALLOC_ARRAY(FVertex3, 4);
    cornerIndices  = ALLOC_ARRAY(uint16_t, 6);
    cornerIndices[0] = 0;
    cornerIndices[1] = 1;
    cornerIndices[2] = 2;
    cornerIndices[3] = 2;
    cornerIndices[4] = 3;
    cornerIndices[5] = 0;

    cornerVertexArray  = [[ NPCPUVertexArray alloc ] init ];
    cornerVertexStream = [[ NPCPUBuffer alloc ] initWithName:@"cornerVertexStream" ];
    cornerIndexStream  = [[ NPCPUBuffer alloc ] initWithName:@"cornerIndexStream"  ];

    NSData * cornerVertexData
        = [ NSData dataWithBytesNoCopy:cornerVertices
                                length:sizeof(FVertex3) * 4
                          freeWhenDone:NO ];

    NSData * cornerIndexData
        = [ NSData dataWithBytesNoCopy:cornerIndices
                                length:sizeof(uint16_t) * 6
                          freeWhenDone:NO ];

    BOOL result
        = [ cornerVertexStream generate:NpBufferObjectTypeGeometry
                             dataFormat:NpBufferDataFormatFloat32
                             components:3
                                   data:cornerVertexData
                                  error:NULL ];

    result
        = result && [ cornerIndexStream generate:NpBufferObjectTypeIndices
                                      dataFormat:NpBufferDataFormatUInt16
                                      components:1
                                            data:cornerIndexData
                                           error:NULL ];

    result
        = result && [ cornerVertexArray setVertexStream:cornerVertexStream 
                                             atLocation:NpVertexStreamPositions
                                                  error:NULL ];

    result
        = result && [ cornerVertexArray setIndexStream:cornerIndexStream 
                                                 error:NULL ];

    NSAssert(result != NO, @"");

	return self;
}

- (void) dealloc
{
    SAFE_DESTROY(projector);
    DESTROY(cornerVertexArray);
    DESTROY(cornerIndexStream);
    DESTROY(cornerVertexStream);
    FREE(cornerVertices);
    FREE(cornerIndices);

	[ super dealloc ];
}

- (void) setProjector:(ODProjector *)newProjector;
{
    ASSIGN(projector, newProjector);
}

- (void) update:(const double)frameTime
{
    NSAssert(projector != nil, @"No projector attached to ODBasePlane");

    const Vector2 upperLeft  = {-1.0,  1.0};
    const Vector2 upperRight = { 1.0,  1.0};
    const Vector2 lowerLeft  = {-1.0, -1.0};
    const Vector2 lowerRight = { 1.0, -1.0};

    const Matrix4 * const invViewProjection = [ projector inverseViewProjection ];
    
    cornerVertices[0] = computeBasePlanePosition(invViewProjection, basePlane, lowerLeft);
    cornerVertices[1] = computeBasePlanePosition(invViewProjection, basePlane, lowerRight);
    cornerVertices[2] = computeBasePlanePosition(invViewProjection, basePlane, upperRight);
    cornerVertices[3] = computeBasePlanePosition(invViewProjection, basePlane, upperLeft);

    /*
    NSLog(@"ul %s", fv3_v_to_string(&cornerVertices[0]));
    NSLog(@"ur %s", fv3_v_to_string(&cornerVertices[1]));
    NSLog(@"ll %s", fv3_v_to_string(&cornerVertices[2]));
    NSLog(@"lr %s", fv3_v_to_string(&cornerVertices[3]));
    */
}

- (void) render
{
    glVertexAttrib3f(NpVertexStreamNormals, 0.0f, 1.0f, 0.0);
    [ cornerVertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
}

@end

