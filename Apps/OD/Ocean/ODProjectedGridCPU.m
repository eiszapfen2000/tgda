#import "NP.h"

#import "ODProjectedGridCPU.h"

#import "Entities/ODCamera.h"
#import "Entities/ODProjector.h"
#import "Utilities/ODFrustum.h"

#import "ODScene.h"
#import "ODSceneManager.h"
#import "ODCore.h"

@implementation ODProjectedGridCPU

- (id) init
{
    return [ self initWithName:@"ODProjectedGridCPU" ];
}
- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    projectedGridResolution          = iv2_alloc_init();
    projectedGridResolutionLastFrame = iv2_alloc_init();

    mode = NP_NONE;

    basePlaneHeight   =  0.0f;
    upperSurfaceBound =  1.0f;
    lowerSurfaceBound = -1.0f;
    basePlane = fplane_alloc_init_with_components(0.0f, 1.0f, 0.0f, basePlaneHeight);

    surfaceGeometry = [[ NPVertexBuffer alloc ] initWithName:@"SG" parent:self ];

    effect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"ocean_cpu.cgfx" ];

    lowerLeftCornerParameter  = [ effect parameterWithName:@"lowerLeft"  ];
    lowerRightCornerParameter = [ effect parameterWithName:@"lowerRight" ];
    upperRightCornerParameter = [ effect parameterWithName:@"upperRight" ];
    upperLeftCornerParameter  = [ effect parameterWithName:@"upperLeft"  ];
    deltaParameter            = [ effect parameterWithName:@"delta"      ];

    NSAssert(lowerLeftCornerParameter  != NULL && lowerRightCornerParameter != NULL &&
             upperRightCornerParameter != NULL && upperLeftCornerParameter  != NULL &&
             deltaParameter != NULL, @"Corner parameter missing");

    return self;
}

- (void) dealloc
{
    projectedGridResolution          = iv2_free(projectedGridResolution);
    projectedGridResolutionLastFrame = iv2_free(projectedGridResolutionLastFrame);

    [ surfaceGeometry release ];

    [ super dealloc ];
}

- (NpState) mode
{
    return mode;
}

- (IVector2) projectedGridResolution
{
    return *projectedGridResolution;
}

- (void) setMode:(NpState)newMode
{
    mode = newMode;
}

- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution
{
    *projectedGridResolution = newProjectedGridResolution;
}

- (Float) basePlaneHeight
{
    return basePlaneHeight;
}

- (void) setBasePlaneHeight:(Float)newBasePlaneHeight
{
    basePlaneHeight = newBasePlaneHeight;
}

- (Float) upperSurfaceBound
{
    return upperSurfaceBound;
}

- (void)  setUpperSurfaceBound:(Float)newUpperSurfaceBound
{
    upperSurfaceBound = newUpperSurfaceBound;
}

- (Float) lowerSurfaceBound
{
    return lowerSurfaceBound;
}

- (void)  setLowerSurfaceBound:(Float)newLowerSurfaceBound
{
    lowerSurfaceBound = newLowerSurfaceBound;
}

- (void) updateGeometryResolution
{
    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    SAFE_FREE(indices);
    SAFE_FREE(normals);
    SAFE_FREE(texCoords);

    Int vertexCount = V_X(*projectedGridResolution) * V_Y(*projectedGridResolution);
    Int indexCount  = (V_X(*projectedGridResolution) - 1) * (V_Y(*projectedGridResolution) - 1) * 2 * 3;

    nearPlanePostProjectionPositions = ALLOC_ARRAY(Float, vertexCount * 4);
    worldSpacePositions              = ALLOC_ARRAY(Float, vertexCount * 3);
    normals                          = ALLOC_ARRAY(Float, vertexCount * 3);
    texCoords                        = ALLOC_ARRAY(Float, vertexCount * 2);
    indices                          = ALLOC_ARRAY(Int, indexCount);

    Int subIndices[4];
    Int quadrangleIndex;

    // origin lower left

    // Index layout
    // 3 --- 2
    // |     |
    // 0 --- 1

    for ( Int i = 0; i < V_Y(*projectedGridResolution)-1; i++ )
    {
        for ( Int j = 0; j < V_X(*projectedGridResolution)-1; j++ )
        {
            subIndices[0] = i * V_X(*projectedGridResolution) + j;
            subIndices[1] = i * V_X(*projectedGridResolution) + j + 1;
            subIndices[2] = (i + 1) * V_X(*projectedGridResolution) + j + 1;
            subIndices[3] = (i + 1) * V_X(*projectedGridResolution) + j;

            quadrangleIndex = (i * (V_X(*projectedGridResolution)-1) + j) * 6;

            indices[quadrangleIndex]   = subIndices[0];
            indices[quadrangleIndex+1] = subIndices[1];
            indices[quadrangleIndex+2] = subIndices[2];

            indices[quadrangleIndex+3] = subIndices[2];
            indices[quadrangleIndex+4] = subIndices[3];
            indices[quadrangleIndex+5] = subIndices[0];
        }
    }

    [ surfaceGeometry setIndices:indices indexCount:indexCount ];

    Int index;
    Float deltaX = 2.0f/(V_X(*projectedGridResolution) - 1.0f);
    Float deltaY = 2.0f/(V_Y(*projectedGridResolution) - 1.0f);

    for ( Int i = 0; i < V_Y(*projectedGridResolution); i++ )
    {
        for ( Int j = 0; j < V_X(*projectedGridResolution); j++ )
        {
            index = (i * V_X(*projectedGridResolution) + j) * 4;
            nearPlanePostProjectionPositions[index]   = -1.0f + j*deltaX;
            nearPlanePostProjectionPositions[index+1] = -1.0f + i*deltaY;
            nearPlanePostProjectionPositions[index+2] = -1.0f;
            nearPlanePostProjectionPositions[index+3] =  1.0f;
        }
    }

    deltaX = 1.0f/(V_X(*projectedGridResolution) - 1.0f);
    deltaY = 1.0f/(V_Y(*projectedGridResolution) - 1.0f);

    Float u = 0.0f;
    Float v = 0.0f;

    for ( Int i = 0; i < V_Y(*projectedGridResolution); i++ )
    {
        u = 0.0f;

        for ( Int j = 0; j < V_X(*projectedGridResolution); j++ )
        {
            index = (i * V_X(*projectedGridResolution) + j) * 2;

            texCoords[index]   = u;
            texCoords[index+1] = v;

            u = u + deltaX;
        }

        v = v + deltaY;
    }

    for ( Int i = 0; i < V_Y(*projectedGridResolution); i++ )
    {
        for ( Int j = 0; j < V_X(*projectedGridResolution); j++ )
        {
            index = (i * V_X(*projectedGridResolution) + j) * 3;
            normals[index]   = 0.0f;
            normals[index+1] = 1.0f;
            normals[index+2] = 0.0f;
        }
    }
}


// Project the grid on the nearplane to the baseplane using raycasting
- (void) calculateBasePlanePositions
{
    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    FMatrix4 * inverseViewProjection = [ projector inverseViewProjection ];

    FVector3 wPosition;
    FRay ray;
    FVector4  tmp, resultN, resultF;
    Int index;

    for ( Int i = 0; i < V_Y(*projectedGridResolution); i++ )
    {
        for ( Int j = 0; j < V_X(*projectedGridResolution); j++ )
        {
            index = (i * V_X(*projectedGridResolution) + j) * 4;
            tmp.x = nearPlanePostProjectionPositions[index];
            tmp.y = nearPlanePostProjectionPositions[index+1];
            tmp.z = -1.0f;
            tmp.w =  1.0f;

            fm4_mv_multiply_v(inverseViewProjection, &tmp, &resultN);

            tmp.z = 1.0f;

            fm4_mv_multiply_v(inverseViewProjection, &tmp, &resultF);

            ray.point.x = resultN.x / resultN.w;
            ray.point.y = resultN.y / resultN.w;
            ray.point.z = resultN.z / resultN.w;

            ray.direction.x = resultF.x / resultF.w - ray.point.x;
            ray.direction.y = resultF.y / resultF.w - ray.point.y;
            ray.direction.z = resultF.z / resultF.w - ray.point.z;

            fplane_pr_intersect_with_ray_v(basePlane, &ray, &wPosition);

            index = (i * V_X(*projectedGridResolution) + j) * 3;

            worldSpacePositions[index]   = wPosition.x;
            worldSpacePositions[index+1] = wPosition.y;
            worldSpacePositions[index+2] = wPosition.z;
        }
    }
}

- (FVector4) unprojectX:(Float)x andY:(Float)y
{
    FVector4 tmpN = {x, y, -1.0f, 1.0f };
    FVector4 tmpF = {x, y,  1.0f, 1.0f };

    ODProjector * projector = [[[[ NP applicationController ] sceneManager ] currentScene ] projector ];
    FMatrix4 * inverseViewProjection = [ projector inverseViewProjection ];

    FVector4 resultN, resultF;
    fm4_mv_multiply_v(inverseViewProjection, &tmpN, &resultN);
    fm4_mv_multiply_v(inverseViewProjection, &tmpF, &resultF);

    fv4_vv_sub_v(&resultF, &resultN, &resultF);

    Float t = (resultN.w * basePlane->d - resultN.y) / ( resultF.y - resultF.w * basePlane->d );

    FVector4 result;
    fv4_sv_scale_v(&t, &resultF, &result);
    fv4_vv_add_v(&result, &resultN, &result);

    return result;
}

// Project the near plane's grid four corner vertices to the baseplane,
// then interpolate the rest of the geometry using those.
- (void) calculateBasePlanePositionsUsingInterpolation
{
    FVector4 upperLeftCorner  = [ self unprojectX:-1.0f andY: 1.0f ];
    FVector4 lowerLeftCorner  = [ self unprojectX:-1.0f andY:-1.0f ];
    FVector4 upperRightCorner = [ self unprojectX: 1.0f andY: 1.0f ];
    FVector4 lowerRightCorner = [ self unprojectX: 1.0f andY:-1.0f ];

    Float u = -1.0f;
    Float v = -1.0f;

    Float deltaX = 2.0f/(V_X(*projectedGridResolution) - 1.0f);
    Float deltaY = 2.0f/(V_Y(*projectedGridResolution) - 1.0f);

    Int index;

    for ( Int i = 0; i < V_Y(*projectedGridResolution); i++ )
    {
        u = -1.0f;

        for ( Int j = 0; j < V_X(*projectedGridResolution); j++ )
        {
            index = (i * V_X(*projectedGridResolution) + j) * 3;

            Float w = (lowerLeftCorner.w / 4.0f) * (1.0f - u) * (1.0f - v) +
                      (lowerRightCorner.w / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                      (upperLeftCorner.w / 4.0f) * (1.0f - u) * (v + 1.0f) +
                      (upperRightCorner.w / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            worldSpacePositions[index]   = (lowerLeftCorner.x / 4.0f) * (1.0f - u) * (1.0f - v) +
                                           (lowerRightCorner.x / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                                           (upperLeftCorner.x / 4.0f) * (1.0f - u) * (v + 1.0f) +
                                           (upperRightCorner.x / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            worldSpacePositions[index] = worldSpacePositions[index] / w;

            worldSpacePositions[index+2] = (lowerLeftCorner.z / 4.0f) * (1.0f - u) * (1.0f - v) +
                                           (lowerRightCorner.z / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                                           (upperLeftCorner.z / 4.0f) * (1.0f - u) * (v + 1.0f) +
                                           (upperRightCorner.z / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            worldSpacePositions[index+2] = worldSpacePositions[index+2] / w;

            worldSpacePositions[index+1] = 0.0f;

            u = u + deltaX;
        }

        v = v + deltaY;
    }
}

- (void) calculateNormals
{
    for ( Int i = 1; i < V_Y(*projectedGridResolution) - 1; i++ )
    {
        for ( Int j = 1; j < V_X(*projectedGridResolution) - 1; j++ )
        {
            Int indexLeftX   = (i * V_X(*projectedGridResolution) + j - 1) * 3;
            Int indexRightX  = (i * V_X(*projectedGridResolution) + j + 1) * 3;
            Int indexTopY    = ((i + 1) * V_X(*projectedGridResolution) + j) * 3;
            Int indexBottomY = ((i - 1) * V_X(*projectedGridResolution) + j) * 3;
            
            FVector3 a = { worldSpacePositions[indexRightX] - worldSpacePositions[indexLeftX] , 0.0f, 0.0f };
            FVector3 b = { 0.0f, 0.0f, worldSpacePositions[indexTopY+2]  - worldSpacePositions[indexBottomY+2] };

            FVector3 normal;
            fv3_vv_cross_product_v(&a, &b, &normal);

            Int index = (i * V_X(*projectedGridResolution) + j) * 3;
            normals[index]   = normal.x;
            normals[index+1] = normal.y;
            normals[index+2] = normal.z;
        }
    }
}

- (void) update
{
    if ( V_X(*projectedGridResolution) != V_X(*projectedGridResolutionLastFrame) ||
         V_Y(*projectedGridResolution) != V_Y(*projectedGridResolutionLastFrame) )
    {
        iv2_v_copy_v(projectedGridResolution, projectedGridResolutionLastFrame);

        [ self updateGeometryResolution ];

        Int vertexCount = V_X(*projectedGridResolution) * V_Y(*projectedGridResolution);
        [ surfaceGeometry setPositions:worldSpacePositions 
                   elementsForPosition:3 
                            dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                           vertexCount:vertexCount ];

        [ surfaceGeometry setNormals:normals
                   elementsForNormal:3 
                          dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT ];

        [ surfaceGeometry setTextureCoordinates:texCoords
                  elementsForTextureCoordinates:2
                                     dataFormat:NP_GRAPHICS_VBO_DATAFORMAT_FLOAT
                                         forSet:0 ];
    }

    switch ( mode )
    {
        case OD_PROJECT_ENTIRE_MESH_ON_CPU:
        case OD_PROJECT_USING_INTERPOLATION_ON_CPU:
        {
            [ self calculateBasePlanePositionsUsingInterpolation ];
            [ self calculateNormals ];

            break;
        }

        case OD_PROJECT_CPU_CORNERS_GPU_INTERPOLATION:
        {
            break;
        }

        default:
        {
            NPLOG_ERROR(@"%@: Invalid mode %d", name, mode);

            break;
        }

    }
}

- (void) render
{
    switch ( mode )
    {
        case OD_PROJECT_ENTIRE_MESH_ON_CPU:
        case OD_PROJECT_USING_INTERPOLATION_ON_CPU:
        {
            [ effect activateTechniqueWithName:@"ocean_cpu" ];
            [ surfaceGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
            [ effect deactivate ];

            break;
        }

        case OD_PROJECT_CPU_CORNERS_GPU_INTERPOLATION:
        {
            FVector4 upperLeftCorner  = [ self unprojectX:-1.0f andY: 1.0f ];
            FVector4 lowerLeftCorner  = [ self unprojectX:-1.0f andY:-1.0f ];
            FVector4 upperRightCorner = [ self unprojectX: 1.0f andY: 1.0f ];
            FVector4 lowerRightCorner = [ self unprojectX: 1.0f andY:-1.0f ];

            FVector2 delta = { 1.0f/(V_X(*projectedGridResolution) - 1.0f), 1.0f/(V_Y(*projectedGridResolution) - 1.0f)}; 

            [ effect uploadFVector4Parameter:lowerLeftCornerParameter  andValue:&lowerLeftCorner  ];
            [ effect uploadFVector4Parameter:lowerRightCornerParameter andValue:&lowerRightCorner ];
            [ effect uploadFVector4Parameter:upperRightCornerParameter andValue:&upperRightCorner ];
            [ effect uploadFVector4Parameter:upperLeftCornerParameter  andValue:&upperLeftCorner  ];
            [ effect uploadFVector2Parameter:deltaParameter            andValue:&delta            ];

            [ effect activateTechniqueWithName:@"ocean_interpolate" ];
            [ surfaceGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_TRIANGLES ];
            [ effect deactivate ];

            break;
        }
    }
}

@end
