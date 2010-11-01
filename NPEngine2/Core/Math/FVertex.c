#include "FVertex.h"

FVertex2 fvertex_as_calculateMassCenter2D(FVertex2 * vertices, size_t numberOfVertices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
    }

    result.x /= (Float)numberOfVertices;
    result.y /= (Float)numberOfVertices;

    return result;
}

FVertex3 fvertex_as_calculateMassCenter3D(FVertex3 * vertices, size_t numberOfVertices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfVertices; i++ )
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

FVertex4 fvertex_as_calculateMassCenter4D(FVertex4 * vertices, size_t numberOfVertices)
{
    FVertex4 result;
    fv4_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfVertices; i++ )
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

FVertex2 fvertex_aass_calculate_indexed_MassCenter2D(FVertex2 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        uint32_t index = indices[i];

        if ( index < numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
        }
    }

    result.x /= (Float)numberOfIndices;
    result.y /= (Float)numberOfIndices;

    return result;
}

FVertex3 fvertex_aass_calculate_indexed_MassCenter3D(FVertex3 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        uint32_t index = indices[i];

        if ( index < numberOfVertices )
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

FVertex4 fvertex_aass_calculate_indexed_MassCenter4D(FVertex4 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices)
{
    FVertex4 result;
    fv4_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        uint32_t index = indices[i];

        if ( index < numberOfVertices )
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
