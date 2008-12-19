#import "ODSurface.h"
#import "ODCamera.h"
#import "ODProjector.h"
#import "ODScene.h"
#import "ODFrustum.h"

#import "Graphics/npgl.h"
#import "Graphics/Model/NPVertexBuffer.h"
#import "Graphics/State/NPStateSet.h"
#import "Graphics/State/NPState.h"

@implementation ODSurface

- (id) init
{
    return [ self initWithParent:nil ];
}
- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"OD Surface" parent:newParent ];
}
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    IVector2 tmp;
    tmp.x = tmp.y = 512;

    return [ self initWithName:newName parent:newParent resolution:&tmp ];
}
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent resolution:(IVector2 *)newResolution
{
    self = [ super initWithName:newName parent:newParent ];

    resolution        = iv2_alloc_init_with_iv2(newResolution);
    currentResolution = iv2_alloc_init_with_components(-1,-1);
    defaultResolution = iv2_alloc_init_with_components(512, 512);

    basePlaneHeight   =  0.0f;
    upperSurfaceBound =  1.0f;
    lowerSurfaceBound = -1.0f;
    basePlane = fplane_alloc_init_with_components(0.0f,1.0f,0.0f,basePlaneHeight);

    nearPlaneWorldSpacePositions = NULL;
    worldSpacePositions = NULL;

    states = [[ NPStateSet alloc ] initWithName:@"Surface States" parent:self ];
    [ states setPolygonFillFront:NP_POLYGON_FILL_LINE ];
    [ states setPolygonFillBack:NP_POLYGON_FILL_LINE ];
    [ states setCullingEnabled:NO ];

    surfaceGeometry = [[ NPVertexBuffer alloc ] initWithName:@"SG" parent:self ];
    //[ surfaceGeometry setPrimitiveType:NP_VBO_PRIMITIVES_TRIANGLES ];

    return self;
}

- (void) dealloc
{
    resolution        = iv2_free(resolution);
    currentResolution = iv2_free(currentResolution);
    defaultResolution = iv2_free(defaultResolution);

    [ states release ];
    [ surfaceGeometry release ];

    [ super dealloc ];
}

- (void) resetGeometry
{
        if ( nearPlaneWorldSpacePositions != NULL )
        {
            FREE(nearPlaneWorldSpacePositions);
        }

        if ( farPlaneWorldSpacePositions != NULL )
        {
            FREE(farPlaneWorldSpacePositions);
        }

        if ( worldSpacePositions != NULL )
        {
            FREE(worldSpacePositions);
        }

        if ( indices != NULL )
        {
            FREE(indices);
        }
}

- (IVector2 *) resolution
{
    return resolution;
}

- (void) setResolution:(IVector2 *)newResolution
{
    resolution = iv2_free(resolution);
    resolution = iv2_alloc_init_with_iv2(newResolution);
}

- (void) setXAxisResolution:(Int)newX
{
    V_X(*resolution) = newX;
}

- (void) setZAxisResolution:(Int)newZ
{
    V_Y(*resolution) = newZ;
}

- (IVector2 *) defaultResolution
{
    return defaultResolution;
}

- (void) setDefaultResolution:(IVector2 *)newDefaultResolution
{
    *defaultResolution = *newDefaultResolution;
}

- (void) setDefaultXAxisResolution:(Int)newX
{
    V_X(*defaultResolution) = newX;
}

- (void) setDefaultZAxisResolution:(Int)newZ
{
    V_Y(*defaultResolution) = newZ;
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
        Int vertexCount = V_X(*resolution) * V_Y(*resolution);
        Int indexCount  = (V_X(*resolution) - 1) * (V_Y(*resolution) - 1) * 2 * 3;

        nearPlaneWorldSpacePositions     = ALLOC_ARRAY(Float, vertexCount * 3);
        nearPlanePostProjectionPositions = ALLOC_ARRAY(Float, vertexCount * 4);
        farPlaneWorldSpacePositions      = ALLOC_ARRAY(Float, vertexCount * 3);
        worldSpacePositions              = ALLOC_ARRAY(Float, vertexCount * 3);
        indices                          = ALLOC_ARRAY(Int, indexCount);

        Int subIndices[4];
        Int quadrangleIndex;

        for ( Int i = 0; i < V_X(*resolution)-1; i++ )
        {
            for ( Int j = 0; j < V_Y(*resolution)-1; j++ )
            {
                subIndices[0] = i * V_Y(*resolution) + j;
                subIndices[1] = i * V_Y(*resolution) + j + 1;
                subIndices[2] = (i + 1) * V_Y(*resolution) + j + 1;
                subIndices[3] = (i + 1) * V_Y(*resolution) + j;

                quadrangleIndex = (i * (V_Y(*resolution)-1) + j) * 6;

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
        Float deltaX = 2.0f/(V_X(*resolution) - 1.0f);
        Float deltaY = 2.0f/(V_Y(*resolution) - 1.0f);

        for ( Int i = 0; i < V_X(*resolution); i++ )
        {
            for ( Int j = 0; j < V_Y(*resolution); j++ )
            {
                index = (i * V_Y(*resolution) + j)*4;
                nearPlanePostProjectionPositions[index]   = -1.0f + i*deltaX;
                nearPlanePostProjectionPositions[index+1] =  1.0f - j*deltaY;
                nearPlanePostProjectionPositions[index+2] = -1.0f;
                nearPlanePostProjectionPositions[index+3] =  1.0f;

                //NSLog(@"%d %d %f %f",i,j,nearPlanePostProjectionPositions[index],nearPlanePostProjectionPositions[index+1]);
            }
        }
}

- (void) calculatePositionsOn:(NpState)plane
{
    Int planeIndices[4];
    Float * positionsOnPlane;

    switch ( plane )
    {
        case ODSURFACE_NEARPLANE: 
        { 
            planeIndices[0] = NEARPLANE_LOWERLEFT;
            planeIndices[1] = NEARPLANE_LOWERRIGHT;
            planeIndices[2] = NEARPLANE_UPPERRIGHT;
            planeIndices[3] = NEARPLANE_UPPERLEFT;
            positionsOnPlane = nearPlaneWorldSpacePositions;
            break;
        }
        case ODSURFACE_FARPLANE: 
        { 
            planeIndices[0] = FARPLANE_LOWERLEFT;
            planeIndices[1] = FARPLANE_LOWERRIGHT;
            planeIndices[2] = FARPLANE_UPPERRIGHT;
            planeIndices[3] = FARPLANE_UPPERLEFT;
            positionsOnPlane = farPlaneWorldSpacePositions;
            break;
        }
    }

    ODFrustum * frustum = [[ (ODScene *)parent projector ] frustum ];
    FVector3 ** frustumCornerPositions = [ frustum frustumCornerPositions ];

    FVector3 deltaX, deltaY;

    Float intervalSizeX = 1.0f/((Float)V_X(*resolution) - 1.0);
    Float intervalSizeY = 1.0f/((Float)V_Y(*resolution) - 1.0);

    fv3_vv_sub_v(frustumCornerPositions[planeIndices[1]], frustumCornerPositions[planeIndices[0]], &deltaX);
    fv3_vv_sub_v(frustumCornerPositions[planeIndices[1]], frustumCornerPositions[planeIndices[2]], &deltaY);

    fv3_sv_scale(&intervalSizeX, &deltaX);
    fv3_sv_scale(&intervalSizeY, &deltaY);

    FVector3 columnPosition, columnDelta;
    FVector3 rowPosition, rowDelta;
    Float fi, fj;
    Int index;

    for ( Int i = 0; i < V_X(*resolution); i++ )
    {
        fi = (Float)i;

        fv3_sv_scale_v(&fi, &deltaX, &columnDelta);
        fv3_vv_add_v(frustumCornerPositions[planeIndices[3]], &columnDelta, &columnPosition);

        for ( Int j = 0; j < V_Y(*resolution); j++ )
        {
            fj = (Float)j;

            fv3_sv_scale_v(&fj, &deltaY, &rowDelta);
            fv3_vv_add_v(&columnPosition, &rowDelta, &rowPosition);

            index = (i * V_Y(*resolution) + j) * 3;
            positionsOnPlane[index]   = rowPosition.x;
            positionsOnPlane[index+1] = rowPosition.y;
            positionsOnPlane[index+2] = rowPosition.z;
        }
    }
}

- (void) calculateBasePlanePositions
{
    FVector3 nV, fV, direction, wPosition;
    FRay ray;

    Int index;
    for ( Int i = 0; i < V_X(*resolution); i++ )
    {
        for ( Int j = 0; j < V_Y(*resolution); j++ )
        {
            index = (i * V_Y(*resolution) + j) * 3;
            nV.x = nearPlaneWorldSpacePositions[index];
            nV.y = nearPlaneWorldSpacePositions[index+1];
            nV.z = nearPlaneWorldSpacePositions[index+2];

            //NSLog(@"w near %f %f %f",nV.x,nV.y,nV.z);

            fV.x = farPlaneWorldSpacePositions[index];
            fV.y = farPlaneWorldSpacePositions[index+1];
            fV.z = farPlaneWorldSpacePositions[index+2];

           // NSLog(@"w far %f %f %f",fV.x,fV.y,fV.z);

            fv3_vv_sub_v(&fV, &nV, &direction);
            fv3_v_normalise(&direction);

            ray.point = nV;
            ray.direction = direction;

            fplane_pr_intersect_with_ray_v(basePlane, &ray, &wPosition);

            worldSpacePositions[index]   = wPosition.x;
            worldSpacePositions[index+1] = wPosition.y;
            worldSpacePositions[index+2] = wPosition.z;

            //NSLog(@"world %f %f %f",wPosition.x,wPosition.y,wPosition.z);
        }
    }

    FMatrix4 * inverseViewProjection = [[ (ODScene *)parent projector ] inverseViewProjection ];

    FVector4  tmp, resultN, resultF;
    for ( Int i = 0; i < V_X(*resolution); i++ )
    {
        for ( Int j = 0; j < V_Y(*resolution); j++ )
        {
            index = (i * V_Y(*resolution) + j) * 4;
            tmp.x = nearPlanePostProjectionPositions[index];
            tmp.y = nearPlanePostProjectionPositions[index+1];
            tmp.z = -1.0f;
            tmp.w =  1.0f;

            fm4_mv_multiply_v(inverseViewProjection,&tmp,&resultN);

            //NSLog(@"near %f %f %f",resultN.x/resultN.w,resultN.y/resultN.w,resultN.z/resultN.w);

            tmp.z = 1.0f;

            fm4_mv_multiply_v(inverseViewProjection,&tmp,&resultF);
//
            //NSLog(@"far %f %f %f",resultF.x/resultF.w,resultF.y/resultF.w,resultF.z/resultF.w);

            ray.point.x = resultN.x / resultN.w;
            ray.point.y = resultN.y / resultN.w;
            ray.point.z = resultN.z / resultN.w;

            ray.direction.x = resultF.x / resultF.w - ray.point.x;
            ray.direction.y = resultF.y / resultF.w - ray.point.y;
            ray.direction.z = resultF.z / resultF.w - ray.point.z;

            fplane_pr_intersect_with_ray_v(basePlane, &ray, &wPosition);
            //NSLog(@"screen %f %f %f",wPosition.x,wPosition.y,wPosition.z);
        }
    }
}

- (void) update
{
    if ( V_X(*resolution) != V_X(*currentResolution) || V_Y(*resolution) != V_Y(*currentResolution) )
    {
        V_X(*currentResolution) = V_X(*resolution);
        V_Y(*currentResolution) = V_Y(*resolution);

        [ self resetGeometry  ];
        [ self updateGeometryResolution ];
    }

    [ self calculatePositionsOn:ODSURFACE_NEARPLANE ];
    [ self calculatePositionsOn:ODSURFACE_FARPLANE  ];

    [ self calculateBasePlanePositions ];

    Int vertexCount = V_X(*currentResolution)*V_Y(*currentResolution);
    [ surfaceGeometry setPositions:worldSpacePositions elementsForPosition:3 vertexCount:vertexCount ];
}

- (void) render
{
    //[ states activate ];

   [ surfaceGeometry render ];
}

@end
