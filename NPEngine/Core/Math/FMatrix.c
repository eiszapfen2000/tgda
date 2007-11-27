#include "FMatrix.h"

NpFreeList * NP_FMATRIX2_FREELIST = NULL;
NpFreeList * NP_FMATRIX3_FREELIST = NULL;
NpFreeList * NP_FMATRIX4_FREELIST = NULL;

void npmath_fmatrix_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FMATRIX2_FREELIST,FMatrix2,512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX3_FREELIST,FMatrix3,512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX4_FREELIST,FMatrix4,512)
}

void fm2_set_identity(FMatrix2 * m)
{
    FM_EL(*m,0,0) = FM_EL(*m,1,1) = 1.0;
    FM_EL(*m,0,1) = FM_EL(*m,1,0) = 0.0;
}

void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose)
{
    FM_EL(*transpose,0,0) = FM_EL(*m,0,0);
    FM_EL(*transpose,0,1) = FM_EL(*m,1,0);

    FM_EL(*transpose,1,0) = FM_EL(*m,0,1);
    FM_EL(*transpose,1,1) = FM_EL(*m,1,1);
}

void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) + FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) + FM_EL(*m2,0,1);
    FM_EL(*result,1,0) = FM_EL(*m1,1,0) + FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) + FM_EL(*m2,1,1);
}

void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) - FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) - FM_EL(*m2,0,1);
    FM_EL(*result,1,0) = FM_EL(*m1,1,0) - FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) - FM_EL(*m2,1,1);
}

void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0)*FM_EL(*m2,0,0) + FM_EL(*m1,1,0)*FM_EL(*m2,0,1);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1)*FM_EL(*m2,0,0) + FM_EL(*m1,1,1)*FM_EL(*m2,0,1);
    FM_EL(*result,1,0) = FM_EL(*m1,0,0)*FM_EL(*m2,1,0) + FM_EL(*m1,1,0)*FM_EL(*m2,1,1);
    FM_EL(*result,1,1) = FM_EL(*m1,0,1)*FM_EL(*m2,1,0) + FM_EL(*m1,1,1)*FM_EL(*m2,1,1);
}

void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result)
{
    FV_X(*result) = FV_X(*v) * FM_EL(*m,0,0) + FV_Y(*v) * FM_EL(*m,0,1);
    FV_Y(*result) = FV_X(*v) * FM_EL(*m,1,0) + FV_Y(*v) * FM_EL(*m,1,1);
}

void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result)
{
    FV_X(*result) = FM_EL(*m,0,0) * FV_X(*v) + FM_EL(*m,1,0) * FV_Y(*v);
    FV_Y(*result) = FM_EL(*m,0,1) * FV_X(*v) + FM_EL(*m,1,1) * FV_Y(*v);
}

FMatrix2 * fm2_alloc()
{
    return (FMatrix2 *)npfreenode_alloc(NP_FMATRIX2_FREELIST);
}

FMatrix2 * fm2_alloc_init()
{
    FMatrix2 * tmp = npfreenode_alloc(NP_FMATRIX2_FREELIST);
    fm2_set_identity(tmp);

    return tmp;
}

void fm3_set_identity(FMatrix3 * m)
{
    FM_EL(*m,0,0) = FM_EL(*m,1,1) = FM_EL(*m,2,2) = 1.0;
    FM_EL(*m,0,1) = FM_EL(*m,0,2) = FM_EL(*m,1,0) = FM_EL(*m,1,2) = FM_EL(*m,2,0) = FM_EL(*m,2,1) = 0.0;
}

void fm3_m_transpose_m(const FMatrix3 * const m, FMatrix3 * transpose)
{
    FM_EL(*transpose,0,0) = FM_EL(*m,0,0);
    FM_EL(*transpose,0,1) = FM_EL(*m,1,0);
    FM_EL(*transpose,0,2) = FM_EL(*m,2,0);

    FM_EL(*transpose,1,0) = FM_EL(*m,0,1);
    FM_EL(*transpose,1,1) = FM_EL(*m,1,1);
    FM_EL(*transpose,1,2) = FM_EL(*m,2,1);

    FM_EL(*transpose,2,0) = FM_EL(*m,0,2);
    FM_EL(*transpose,2,1) = FM_EL(*m,1,2);
    FM_EL(*transpose,2,2) = FM_EL(*m,2,2);
}

void fm3_mm_add_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) + FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) + FM_EL(*m2,0,1);
    FM_EL(*result,0,2) = FM_EL(*m1,0,2) + FM_EL(*m2,0,2);

    FM_EL(*result,1,0) = FM_EL(*m1,1,0) + FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) + FM_EL(*m2,1,1);
    FM_EL(*result,1,2) = FM_EL(*m1,1,2) + FM_EL(*m2,1,2);

    FM_EL(*result,2,0) = FM_EL(*m1,2,0) + FM_EL(*m2,2,0);
    FM_EL(*result,2,1) = FM_EL(*m1,2,1) + FM_EL(*m2,2,1);
    FM_EL(*result,2,2) = FM_EL(*m1,2,2) + FM_EL(*m2,2,2);
}

void fm3_mm_subtract_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) - FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) - FM_EL(*m2,0,1);
    FM_EL(*result,0,2) = FM_EL(*m1,0,2) - FM_EL(*m2,0,2);

    FM_EL(*result,1,0) = FM_EL(*m1,1,0) - FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) - FM_EL(*m2,1,1);
    FM_EL(*result,1,2) = FM_EL(*m1,1,2) - FM_EL(*m2,1,2);

    FM_EL(*result,2,0) = FM_EL(*m1,2,0) - FM_EL(*m2,2,0);
    FM_EL(*result,2,1) = FM_EL(*m1,2,1) - FM_EL(*m2,2,1);
    FM_EL(*result,2,2) = FM_EL(*m1,2,2) - FM_EL(*m2,2,2);
}

void fm3_mm_multiply_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0)*FM_EL(*m2,0,0) + FM_EL(*m1,1,0)*FM_EL(*m2,0,1) + FM_EL(*m1,2,0)*FM_EL(*m2,0,2);
    FM_EL(*result,1,0) = FM_EL(*m1,0,0)*FM_EL(*m2,1,0) + FM_EL(*m1,1,0)*FM_EL(*m2,1,1) + FM_EL(*m1,2,0)*FM_EL(*m2,1,2);
    FM_EL(*result,2,0) = FM_EL(*m1,0,0)*FM_EL(*m2,2,0) + FM_EL(*m1,1,0)*FM_EL(*m2,2,1) + FM_EL(*m1,2,0)*FM_EL(*m2,2,2);

    FM_EL(*result,0,1) = FM_EL(*m1,0,1)*FM_EL(*m2,0,0) + FM_EL(*m1,1,1)*FM_EL(*m2,0,1) + FM_EL(*m1,2,1)*FM_EL(*m2,0,2);
    FM_EL(*result,1,1) = FM_EL(*m1,0,1)*FM_EL(*m2,1,0) + FM_EL(*m1,1,1)*FM_EL(*m2,1,1) + FM_EL(*m1,2,1)*FM_EL(*m2,1,2);
    FM_EL(*result,2,1) = FM_EL(*m1,0,1)*FM_EL(*m2,2,0) + FM_EL(*m1,1,1)*FM_EL(*m2,2,1) + FM_EL(*m1,2,1)*FM_EL(*m2,2,2);

    FM_EL(*result,0,2) = FM_EL(*m1,0,2)*FM_EL(*m2,0,0) + FM_EL(*m1,1,2)*FM_EL(*m2,0,1) + FM_EL(*m1,2,2)*FM_EL(*m2,0,2);
    FM_EL(*result,1,2) = FM_EL(*m1,0,2)*FM_EL(*m2,1,0) + FM_EL(*m1,1,2)*FM_EL(*m2,1,1) + FM_EL(*m1,2,2)*FM_EL(*m2,1,2);
    FM_EL(*result,2,2) = FM_EL(*m1,0,2)*FM_EL(*m2,2,0) + FM_EL(*m1,1,2)*FM_EL(*m2,2,1) + FM_EL(*m1,2,2)*FM_EL(*m2,2,2);
}

void fm3_vm_multiply_v(const FVector3 * const v, const FMatrix3 * const m, FVector3 * result)
{
    FV_X(*result) = FV_X(*v) * FM_EL(*m,0,0) + FV_Y(*v) * FM_EL(*m,0,1) + FV_Z(*v) * FM_EL(*m,0,2);
    FV_Y(*result) = FV_X(*v) * FM_EL(*m,1,0) + FV_Y(*v) * FM_EL(*m,1,1) + FV_Z(*v) * FM_EL(*m,1,2);
    FV_Z(*result) = FV_X(*v) * FM_EL(*m,2,0) + FV_Y(*v) * FM_EL(*m,2,1) + FV_Z(*v) * FM_EL(*m,2,2);
}

void fm3_mv_multiply_v(const FMatrix3 * const m, const FVector3 * const v, FVector3 * result)
{
    FV_X(*result) = FM_EL(*m,0,0) * FV_X(*v) + FM_EL(*m,1,0) * FV_Y(*v) + FM_EL(*m,2,0) * FV_Z(*v);
    FV_Y(*result) = FM_EL(*m,0,1) * FV_X(*v) + FM_EL(*m,1,1) * FV_Y(*v) + FM_EL(*m,2,1) * FV_Z(*v);
    FV_Z(*result) = FM_EL(*m,0,2) * FV_X(*v) + FM_EL(*m,1,2) * FV_Y(*v) + FM_EL(*m,2,2) * FV_Z(*v);
}

FMatrix3 * fm3_alloc()
{
    return (FMatrix3 *)npfreenode_alloc(NP_FMATRIX3_FREELIST);
}

FMatrix3 * fm3_alloc_init()
{
    FMatrix3 * tmp = npfreenode_alloc(NP_FMATRIX3_FREELIST);
    fm3_set_identity(tmp);

    return tmp;
}

void fm4_set_identity(FMatrix4 * m)
{
    FM_EL(*m,0,0) = FM_EL(*m,1,1) = FM_EL(*m,2,2) = FM_EL(*m,3,3) = 1.0;
    FM_EL(*m,0,1) = FM_EL(*m,0,2) = FM_EL(*m,0,3) = FM_EL(*m,1,0) = FM_EL(*m,1,2) = FM_EL(*m,1,3) =
    FM_EL(*m,2,0) = FM_EL(*m,2,1) = FM_EL(*m,2,3) = FM_EL(*m,3,0) = FM_EL(*m,3,1) = FM_EL(*m,3,2) = 0.0;
}

void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose)
{
    FM_EL(*transpose,0,0) = FM_EL(*m,0,0);
    FM_EL(*transpose,0,1) = FM_EL(*m,1,0);
    FM_EL(*transpose,0,2) = FM_EL(*m,2,0);
    FM_EL(*transpose,0,3) = FM_EL(*m,3,0);

    FM_EL(*transpose,1,0) = FM_EL(*m,0,1);
    FM_EL(*transpose,1,1) = FM_EL(*m,1,1);
    FM_EL(*transpose,1,2) = FM_EL(*m,2,1);
    FM_EL(*transpose,1,3) = FM_EL(*m,3,1);

    FM_EL(*transpose,2,0) = FM_EL(*m,0,2);
    FM_EL(*transpose,2,1) = FM_EL(*m,1,2);
    FM_EL(*transpose,2,2) = FM_EL(*m,2,2);
    FM_EL(*transpose,2,3) = FM_EL(*m,3,2);

    FM_EL(*transpose,3,0) = FM_EL(*m,0,3);
    FM_EL(*transpose,3,1) = FM_EL(*m,1,3);
    FM_EL(*transpose,3,2) = FM_EL(*m,2,3);
    FM_EL(*transpose,3,3) = FM_EL(*m,3,3);
}

void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) + FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) + FM_EL(*m2,0,1);
    FM_EL(*result,0,2) = FM_EL(*m1,0,2) + FM_EL(*m2,0,2);
    FM_EL(*result,0,3) = FM_EL(*m1,0,3) + FM_EL(*m2,0,3);

    FM_EL(*result,1,0) = FM_EL(*m1,1,0) + FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) + FM_EL(*m2,1,1);
    FM_EL(*result,1,2) = FM_EL(*m1,1,2) + FM_EL(*m2,1,2);
    FM_EL(*result,1,3) = FM_EL(*m1,1,3) + FM_EL(*m2,1,3);

    FM_EL(*result,2,0) = FM_EL(*m1,2,0) + FM_EL(*m2,2,0);
    FM_EL(*result,2,1) = FM_EL(*m1,2,1) + FM_EL(*m2,2,1);
    FM_EL(*result,2,2) = FM_EL(*m1,2,2) + FM_EL(*m2,2,2);
    FM_EL(*result,2,3) = FM_EL(*m1,2,3) + FM_EL(*m2,2,3);

    FM_EL(*result,3,0) = FM_EL(*m1,3,0) + FM_EL(*m2,3,0);
    FM_EL(*result,3,1) = FM_EL(*m1,3,1) + FM_EL(*m2,3,1);
    FM_EL(*result,3,2) = FM_EL(*m1,3,2) + FM_EL(*m2,3,2);
    FM_EL(*result,3,3) = FM_EL(*m1,3,3) + FM_EL(*m2,3,3);
}

void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0) - FM_EL(*m2,0,0);
    FM_EL(*result,0,1) = FM_EL(*m1,0,1) - FM_EL(*m2,0,1);
    FM_EL(*result,0,2) = FM_EL(*m1,0,2) - FM_EL(*m2,0,2);
    FM_EL(*result,0,3) = FM_EL(*m1,0,3) - FM_EL(*m2,0,3);

    FM_EL(*result,1,0) = FM_EL(*m1,1,0) - FM_EL(*m2,1,0);
    FM_EL(*result,1,1) = FM_EL(*m1,1,1) - FM_EL(*m2,1,1);
    FM_EL(*result,1,2) = FM_EL(*m1,1,2) - FM_EL(*m2,1,2);
    FM_EL(*result,1,3) = FM_EL(*m1,1,3) - FM_EL(*m2,1,3);

    FM_EL(*result,2,0) = FM_EL(*m1,2,0) - FM_EL(*m2,2,0);
    FM_EL(*result,2,1) = FM_EL(*m1,2,1) - FM_EL(*m2,2,1);
    FM_EL(*result,2,2) = FM_EL(*m1,2,2) - FM_EL(*m2,2,2);
    FM_EL(*result,2,3) = FM_EL(*m1,2,3) - FM_EL(*m2,2,3);

    FM_EL(*result,3,0) = FM_EL(*m1,3,0) - FM_EL(*m2,3,0);
    FM_EL(*result,3,1) = FM_EL(*m1,3,1) - FM_EL(*m2,3,1);
    FM_EL(*result,3,2) = FM_EL(*m1,3,2) - FM_EL(*m2,3,2);
    FM_EL(*result,3,3) = FM_EL(*m1,3,3) - FM_EL(*m2,3,3);
}

void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    FM_EL(*result,0,0) = FM_EL(*m1,0,0)*FM_EL(*m2,0,0) + FM_EL(*m1,1,0)*FM_EL(*m2,0,1) + FM_EL(*m1,2,0)*FM_EL(*m2,0,2) + FM_EL(*m1,3,0)*FM_EL(*m2,0,3);
    FM_EL(*result,1,0) = FM_EL(*m1,0,0)*FM_EL(*m2,1,0) + FM_EL(*m1,1,0)*FM_EL(*m2,1,1) + FM_EL(*m1,2,0)*FM_EL(*m2,1,2) + FM_EL(*m1,3,0)*FM_EL(*m2,1,3);
    FM_EL(*result,2,0) = FM_EL(*m1,0,0)*FM_EL(*m2,2,0) + FM_EL(*m1,1,0)*FM_EL(*m2,2,1) + FM_EL(*m1,2,0)*FM_EL(*m2,2,2) + FM_EL(*m1,3,0)*FM_EL(*m2,2,3);
    FM_EL(*result,3,0) = FM_EL(*m1,0,0)*FM_EL(*m2,3,0) + FM_EL(*m1,1,0)*FM_EL(*m2,3,1) + FM_EL(*m1,2,0)*FM_EL(*m2,3,2) + FM_EL(*m1,3,0)*FM_EL(*m2,3,3);

    FM_EL(*result,0,1) = FM_EL(*m1,0,1)*FM_EL(*m2,0,0) + FM_EL(*m1,1,1)*FM_EL(*m2,0,1) + FM_EL(*m1,2,1)*FM_EL(*m2,0,2) + FM_EL(*m1,3,1)*FM_EL(*m2,0,3);
    FM_EL(*result,1,1) = FM_EL(*m1,0,1)*FM_EL(*m2,1,0) + FM_EL(*m1,1,1)*FM_EL(*m2,1,1) + FM_EL(*m1,2,1)*FM_EL(*m2,1,2) + FM_EL(*m1,3,1)*FM_EL(*m2,1,3);
    FM_EL(*result,2,1) = FM_EL(*m1,0,1)*FM_EL(*m2,2,0) + FM_EL(*m1,1,1)*FM_EL(*m2,2,1) + FM_EL(*m1,2,1)*FM_EL(*m2,2,2) + FM_EL(*m1,3,1)*FM_EL(*m2,2,3);
    FM_EL(*result,3,1) = FM_EL(*m1,0,1)*FM_EL(*m2,3,0) + FM_EL(*m1,1,1)*FM_EL(*m2,3,1) + FM_EL(*m1,2,1)*FM_EL(*m2,3,2) + FM_EL(*m1,3,1)*FM_EL(*m2,3,3);

    FM_EL(*result,0,2) = FM_EL(*m1,0,2)*FM_EL(*m2,0,0) + FM_EL(*m1,1,2)*FM_EL(*m2,0,1) + FM_EL(*m1,2,2)*FM_EL(*m2,0,2) + FM_EL(*m1,3,2)*FM_EL(*m2,0,3);
    FM_EL(*result,1,2) = FM_EL(*m1,0,2)*FM_EL(*m2,1,0) + FM_EL(*m1,1,2)*FM_EL(*m2,1,1) + FM_EL(*m1,2,2)*FM_EL(*m2,1,2) + FM_EL(*m1,3,2)*FM_EL(*m2,1,3);
    FM_EL(*result,2,2) = FM_EL(*m1,0,2)*FM_EL(*m2,2,0) + FM_EL(*m1,1,2)*FM_EL(*m2,2,1) + FM_EL(*m1,2,2)*FM_EL(*m2,2,2) + FM_EL(*m1,3,2)*FM_EL(*m2,2,3);
    FM_EL(*result,3,2) = FM_EL(*m1,0,2)*FM_EL(*m2,3,0) + FM_EL(*m1,1,2)*FM_EL(*m2,3,1) + FM_EL(*m1,2,2)*FM_EL(*m2,3,2) + FM_EL(*m1,3,2)*FM_EL(*m2,3,3);

    FM_EL(*result,0,3) = FM_EL(*m1,0,3)*FM_EL(*m2,0,0) + FM_EL(*m1,1,3)*FM_EL(*m2,0,1) + FM_EL(*m1,2,3)*FM_EL(*m2,0,2) + FM_EL(*m1,3,3)*FM_EL(*m2,0,3);
    FM_EL(*result,1,3) = FM_EL(*m1,0,3)*FM_EL(*m2,1,0) + FM_EL(*m1,1,3)*FM_EL(*m2,1,1) + FM_EL(*m1,2,3)*FM_EL(*m2,1,2) + FM_EL(*m1,3,3)*FM_EL(*m2,1,3);
    FM_EL(*result,2,3) = FM_EL(*m1,0,3)*FM_EL(*m2,2,0) + FM_EL(*m1,1,3)*FM_EL(*m2,2,1) + FM_EL(*m1,2,3)*FM_EL(*m2,2,2) + FM_EL(*m1,3,3)*FM_EL(*m2,2,3);
    FM_EL(*result,3,3) = FM_EL(*m1,0,3)*FM_EL(*m2,3,0) + FM_EL(*m1,1,3)*FM_EL(*m2,3,1) + FM_EL(*m1,2,3)*FM_EL(*m2,3,2) + FM_EL(*m1,3,3)*FM_EL(*m2,3,3);
}

void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result)
{
    FV_X(*result) = FV_X(*v) * FM_EL(*m,0,0) + FV_Y(*v) * FM_EL(*m,0,1) + FV_Z(*v) * FM_EL(*m,0,2) + FV_W(*v) * FM_EL(*m,0,3);
    FV_Y(*result) = FV_X(*v) * FM_EL(*m,1,0) + FV_Y(*v) * FM_EL(*m,1,1) + FV_Z(*v) * FM_EL(*m,1,2) + FV_W(*v) * FM_EL(*m,1,3);
    FV_Z(*result) = FV_X(*v) * FM_EL(*m,2,0) + FV_Y(*v) * FM_EL(*m,2,1) + FV_Z(*v) * FM_EL(*m,2,2) + FV_W(*v) * FM_EL(*m,2,3);
    FV_W(*result) = FV_X(*v) * FM_EL(*m,3,0) + FV_Y(*v) * FM_EL(*m,3,1) + FV_Z(*v) * FM_EL(*m,3,2) + FV_W(*v) * FM_EL(*m,3,3);
}

void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result)
{
    FV_X(*result) = FM_EL(*m,0,0) * FV_X(*v) + FM_EL(*m,1,0) * FV_Y(*v) + FM_EL(*m,2,0) * FV_Z(*v) + FM_EL(*m,3,0) * FV_W(*v);
    FV_Y(*result) = FM_EL(*m,0,1) * FV_X(*v) + FM_EL(*m,1,1) * FV_Y(*v) + FM_EL(*m,2,1) * FV_Z(*v) + FM_EL(*m,3,1) * FV_W(*v);
    FV_Z(*result) = FM_EL(*m,0,2) * FV_X(*v) + FM_EL(*m,1,2) * FV_Y(*v) + FM_EL(*m,2,2) * FV_Z(*v) + FM_EL(*m,3,2) * FV_W(*v);
    FV_W(*result) = FM_EL(*m,0,3) * FV_X(*v) + FM_EL(*m,1,3) * FV_Y(*v) + FM_EL(*m,2,3) * FV_Z(*v) + FM_EL(*m,3,3) * FV_W(*v);
}

FMatrix4 * fm4_alloc()
{
    return (FMatrix4 *)npfreenode_alloc(NP_FMATRIX4_FREELIST);
}

FMatrix4 * fm4_alloc_init()
{
    FMatrix4 * tmp = npfreenode_alloc(NP_FMATRIX4_FREELIST);
    fm4_set_identity(tmp);

    return tmp;
}

