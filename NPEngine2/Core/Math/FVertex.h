#ifndef _NP_MATH_FVERTEX_H_
#define _NP_MATH_FVERTEX_H_

#include "FVector.h"

typedef FVector2 FVertex2;
typedef FVector3 FVertex3;
typedef FVector4 FVertex4;

FVertex2 fvertex_as_calculateMassCenter2D(FVertex2 * vertices, size_t numberOfVertices);
FVertex3 fvertex_as_calculateMassCenter3D(FVertex3 * vertices, size_t numberOfVertices);
FVertex4 fvertex_as_calculateMassCenter4D(FVertex4 * vertices, size_t numberOfVertices);

FVertex2 fvertex_aass_calculate_indexed_MassCenter2D(FVertex2 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices);
FVertex3 fvertex_aass_calculate_indexed_MassCenter3D(FVertex3 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices);
FVertex4 fvertex_aass_calculate_indexed_MassCenter4D(FVertex4 * vertices, uint32_t * indices, size_t numberOfVertices, size_t numberOfIndices);

#endif
