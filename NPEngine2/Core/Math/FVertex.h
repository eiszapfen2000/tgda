#ifndef _NP_MATH_FVERTEX_H_
#define _NP_MATH_FVERTEX_H_

#include "FVector.h"

typedef FVector2 FVertex2;
typedef FVector3 FVertex3;
typedef FVector4 FVertex4;

FVertex2 fvertex_as_masscenter_2d(const FVertex2 * const vertices,
    const size_t numberOfVertices);
FVertex3 fvertex_as_masscenter_3d(const FVertex3 * const vertices,
    const size_t numberOfVertices);
FVertex4 fvertex_as_masscenter_4d(const FVertex4 * const vertices,
    const size_t numberOfVertices);

FVertex2 fvertex_aass_masscenter_2d_indexed(const FVertex2 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices);

FVertex3 fvertex_aass_masscenter_3d_indexed(const FVertex3 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices);

FVertex4 fvertex_aass_masscenter_4d_indexed(const FVertex4 * const vertices,
    const uint32_t * const indices, const size_t numberOfVertices,
    const size_t numberOfIndices);

#endif
