#include "FVertex.h"

FVertex2 fvertex_as_masscenter_2d(const FVertex2 * const vertices,
    const size_t numberOfVertices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
    }

    result.x /= (float)numberOfVertices;
    result.y /= (float)numberOfVertices;

    return result;
}

FVertex3 fvertex_as_masscenter_3d(const FVertex3 * const vertices,
    const size_t numberOfVertices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfVertices; i++ )
    {
        result.x += vertices[i].x;
        result.y += vertices[i].y;
        result.z += vertices[i].z;
    }

    result.x /= (float)numberOfVertices;
    result.y /= (float)numberOfVertices;
    result.z /= (float)numberOfVertices;

    return result;
}

FVertex4 fvertex_as_masscenter_4d(const FVertex4 * const vertices,
    const size_t numberOfVertices)
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

    result.x /= (float)numberOfVertices;
    result.y /= (float)numberOfVertices;
    result.z /= (float)numberOfVertices;
    result.w /= (float)numberOfVertices;

    return result;
}

FVertex2 fvertex_aass_masscenter_2d_indexed(const FVertex2 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices)
{
    FVertex2 result;
    fv2_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        const uint32_t index = indices[i];

        if ( index < numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
        }
    }

    result.x /= (float)numberOfIndices;
    result.y /= (float)numberOfIndices;

    return result;
}

FVertex3 fvertex_aass_masscenter_3d_indexed(const FVertex3 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices)
{
    FVertex3 result;
    fv3_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        const uint32_t index = indices[i];

        if ( index < numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
            result.z += vertices[indices[i]].z;
        }
    }

    result.x /= (float)numberOfIndices;
    result.y /= (float)numberOfIndices;
    result.z /= (float)numberOfIndices;

    return result;
}

FVertex4 fvertex_aass_masscenter_4d_indexed(const FVertex4 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices)
{
    FVertex4 result;
    fv4_v_init_with_zeros(&result);

    for ( size_t i = 0; i < numberOfIndices; i++ )
    {
        const uint32_t index = indices[i];

        if ( index < numberOfVertices )
        {
            result.x += vertices[indices[i]].x;
            result.y += vertices[indices[i]].y;
            result.z += vertices[indices[i]].z;
            result.w += vertices[indices[i]].w;
        }
    }

    result.x /= (float)numberOfIndices;
    result.y /= (float)numberOfIndices;
    result.z /= (float)numberOfIndices;
    result.w /= (float)numberOfIndices;

    return result;
}
