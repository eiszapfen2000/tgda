#include "FVertex.h"

FVertex2 fvertex_as_calculateMassCenter2D(FVertex2 * vertices, UInt32 numberOfVertices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
    }

    result.x /= (Float)numberOfVertices;
    result.y /= (Float)numberOfVertices;

    return result;
}

FVertex3 fvertex_as_calculateMassCenter3D(FVertex3 * vertices, UInt32 numberOfVertices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
        result.z += vertices[i].z;
    }

    result.x /= (Float)numberOfVertices;
    result.y /= (Float)numberOfVertices;
    result.z /= (Float)numberOfVertices;

    return result;
}

FVertex4 fvertex_as_calculateMassCenter4D(FVertex4 * vertices, UInt32 numberOfVertices)
{
    FVertex4 result;
    fv4_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
        result.z += vertices[i].z;
        result.w += vertices[i].w;
    }

    result.x /= (Float)numberOfVertices;
    result.y /= (Float)numberOfVertices;
    result.z /= (Float)numberOfVertices;
    result.w /= (Float)numberOfVertices;

    return result;
}

FVertex2 fvertex_aass_calculate_indexed_MassCenter2D(FVertex2 * vertices, Int32 * indices, UInt32 numberOfVertices, UInt32 numberOfIndices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfIndices; i++ )
    {
        Int32 index = indices[i];

        if ( index < (Int32)numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
        }
    }

    result.x /= (Float)numberOfIndices;
    result.y /= (Float)numberOfIndices;

    return result;
}

FVertex3 fvertex_aass_calculate_indexed_MassCenter3D(FVertex3 * vertices, Int32 * indices, UInt32 numberOfVertices, UInt32 numberOfIndices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfIndices; i++ )
    {
        Int32 index = indices[i];

        if ( index < (Int32)numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
            result.z += vertices[indices[i]].z;
        }
    }

    result.x /= (Float)numberOfIndices;
    result.y /= (Float)numberOfIndices;
    result.z /= (Float)numberOfIndices;

    return result;
}

FVertex4 fvertex_aass_calculate_indexed_MassCenter4D(FVertex4 * vertices, Int32 * indices, UInt32 numberOfVertices, UInt32 numberOfIndices)
{
    FVertex4 result;
    fv4_v_init_with_zeros(&result);

    for ( UInt32 i = 0; i < numberOfIndices; i++ )
    {
        Int32 index = indices[i];

        if ( index < (Int32)numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
            result.z += vertices[indices[i]].z;
            result.w += vertices[indices[i]].w;
        }
    }

    result.x /= (Float)numberOfIndices;
    result.y /= (Float)numberOfIndices;
    result.z /= (Float)numberOfIndices;
    result.w /= (Float)numberOfIndices;

    return result;
}
