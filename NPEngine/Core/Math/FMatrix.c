#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "FMatrix.h"
#include "Utilities.h"

NpFreeList * NP_FMATRIX2_FREELIST = NULL;
NpFreeList * NP_FMATRIX3_FREELIST = NULL;
NpFreeList * NP_FMATRIX4_FREELIST = NULL;

void npmath_fmatrix_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FMATRIX2_FREELIST,FMatrix2,512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX3_FREELIST,FMatrix3,512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX4_FREELIST,FMatrix4,512)
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

FMatrix2 * fm2_free(FMatrix2 * v)
{
    return npfreenode_fast_free(v,NP_FMATRIX2_FREELIST);
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

void fm2_m_inverse_m(const FMatrix2 * const m1, FMatrix2 * m2)
{
    Float determinant = fm2_determinant(m1);

    if ( determinant == 0.0f )
    {
        return;
    }

    Float scalar = 1.0f/determinant;

    FM_EL(*m2,0,0) = scalar * FM_EL(*m1,1,1);
    FM_EL(*m2,0,1) = scalar * -FM_EL(*m1,0,1);
    FM_EL(*m2,1,0) = scalar * -FM_EL(*m1,1,0);
    FM_EL(*m2,1,1) = scalar * FM_EL(*m1,0,0);
}

Float fm2_determinant(const FMatrix2 * const m)
{
    return FM_EL(*m,0,0) * FM_EL(*m,1,1) - FM_EL(*m,0,1)*FM_EL(*m,1,0);
}

const char * fm2_m_to_string(FMatrix2 * m)
{
    char * fm2string;

    if ( asprintf(&fm2string, "%f %f\n%f %f\n",
                  FM_EL(*m,0,0),FM_EL(*m,1,0),
                  FM_EL(*m,0,1),FM_EL(*m,1,1)) < 0)
    {
        return NULL;
    }

    return fm2string;
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

FMatrix3 * fm3_free(FMatrix3 * v)
{
    return npfreenode_fast_free(v,NP_FMATRIX3_FREELIST);
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

/*
  Providing that the determinant is non-zero, then the inverse is
  calculated as:

     -1     1     |   EI-FH  -(BI-HC)   BF-EC  |
    M   = ----- . | -(DI-FG)   AI-GC  -(AF-DC) |
          det M   |   DH-GE  -(AH-GB)   AE-BD  |
*/

void fm3_m_inverse_m(const FMatrix3 * const m1, FMatrix3 * m2)
{
    Float determinant = fm3_determinant(m1);

    if ( fabs(determinant) < MATH_FLOAT_EPSILON )
    {
        return;
    }

    Float scalar = 1.0f/determinant;

    FM_EL(*m2,0,0) = scalar *   ( FM_EL(*m1,1,1)*FM_EL(*m1,2,2) - FM_EL(*m1,2,1)*FM_EL(*m1,1,2) );
    FM_EL(*m2,0,1) = scalar * (-( FM_EL(*m1,0,1)*FM_EL(*m1,2,2) - FM_EL(*m1,2,1)*FM_EL(*m1,0,2) ));
    FM_EL(*m2,0,2) = scalar *   ( FM_EL(*m1,0,1)*FM_EL(*m1,1,2) - FM_EL(*m1,0,2)*FM_EL(*m1,1,1) );

    FM_EL(*m2,1,0) = scalar * (-( FM_EL(*m1,1,0)*FM_EL(*m1,2,2) - FM_EL(*m1,1,2)*FM_EL(*m1,2,0) ));
    FM_EL(*m2,1,1) = scalar *   ( FM_EL(*m1,0,0)*FM_EL(*m1,2,2) - FM_EL(*m1,0,2)*FM_EL(*m1,2,0) );
    FM_EL(*m2,1,2) = scalar * (-( FM_EL(*m1,0,0)*FM_EL(*m1,1,2) - FM_EL(*m1,0,2)*FM_EL(*m1,1,0) ));

    FM_EL(*m2,2,0) = scalar *   ( FM_EL(*m1,1,0)*FM_EL(*m1,2,1) - FM_EL(*m1,1,1)*FM_EL(*m1,2,0) );
    FM_EL(*m2,2,1) = scalar * (-( FM_EL(*m1,0,0)*FM_EL(*m1,2,1) - FM_EL(*m1,0,1)*FM_EL(*m1,2,0) ));
    FM_EL(*m2,2,2) = scalar *   ( FM_EL(*m1,0,0)*FM_EL(*m1,1,1) - FM_EL(*m1,1,0)*FM_EL(*m1,0,1) );
}


/*
  If Kramer's rule is applied to a matrix M:

        | A B C |
    M = | D E F |
        | G H I |

  then the determinant is calculated as follows:

    det M = A * (EI - HF) - B * (DI - GF) + C * (DH - GE)
*/

Float fm3_determinant(const FMatrix3 * const m)
{
    Float EIminusHF = FM_EL(*m,1,1)*FM_EL(*m,2,2) - FM_EL(*m,1,2)*FM_EL(*m,2,1);
    Float DIminusGF = FM_EL(*m,0,1)*FM_EL(*m,2,2) - FM_EL(*m,0,2)*FM_EL(*m,2,1);
    Float DHminusGE = FM_EL(*m,0,1)*FM_EL(*m,1,2) - FM_EL(*m,0,2)*FM_EL(*m,1,1);

    return FM_EL(*m,0,0) * EIminusHF - FM_EL(*m,1,0) * DIminusGF + FM_EL(*m,2,0) * DHminusGE;
}

const char * fm3_m_to_string(FMatrix3 * m)
{
    char * fm3string;

    if ( asprintf(&fm3string, "%f %f %f\n%f %f %f\n%f %f %f\n",
                  FM_EL(*m,0,0),FM_EL(*m,1,0),FM_EL(*m,2,0),
                  FM_EL(*m,0,1),FM_EL(*m,1,1),FM_EL(*m,2,1),
                  FM_EL(*m,0,2),FM_EL(*m,1,2),FM_EL(*m,2,2)) < 0)
    {
        return NULL;
    }

    return fm3string;
}

FMatrix4 * fm4_alloc()
{
    return (FMatrix4 *)npfreenode_alloc(NP_FMATRIX4_FREELIST);
}

FMatrix4 * fm4_alloc_init()
{
    FMatrix4 * tmp = npfreenode_alloc(NP_FMATRIX4_FREELIST);
    fm4_m_set_identity(tmp);

    return tmp;
}

FMatrix4 * fm4_free(FMatrix4 * v)
{
    return npfreenode_fast_free(v,NP_FMATRIX4_FREELIST);
}

void fm4_m_set_identity(FMatrix4 * m)
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

void fm4_mv_translation_matrix(FMatrix4 * m, FVector3 * v)
{
    fm4_m_set_identity(m);
    FM_EL(*m,3,0) = FV_X(*v);
    FM_EL(*m,3,1) = FV_Y(*v);
    FM_EL(*m,3,2) = FV_Z(*v);
}

void fm4_msss_projection_matrix(FMatrix4 * m, Float aspectratio, Float fovdegrees, Float nearplane, Float farplane)
{
    Float fovradians = DEGREE_TO_RADIANS(fovdegrees/2.0f);
    Float f = 1.0f/tan(fovradians);

    FM_EL(*m,0,0) = f/aspectratio;
    FM_EL(*m,1,1) = f;
    FM_EL(*m,2,2) = (nearplane + farplane)/(nearplane - farplane);
    FM_EL(*m,2,3) = -1.0f;
    FM_EL(*m,3,2) = (2.0f*nearplane*farplane)/(nearplane - farplane);
    FM_EL(*m,3,3) = 0.0f;
}

void fm4_mss_sub_matrix_m(const FMatrix4 * const m, Int row, Int column, FMatrix3 * result)
{
    Int columnIndex = 0;
    Int rowIndex = 0;

    for ( Int i = 0; i < 4; i++ )
    {
        if ( i == column )
        {
            continue;
        }

        for ( Int j = 0; j < 4; j++ )
        {
            if ( j == row )
            {
                continue;
            }

            FM_EL(*result,columnIndex,rowIndex) = FM_EL(*m,i,j);
            rowIndex++;
        }

        columnIndex++;
        rowIndex = 0;
    }
}


void fm4_m_inverse_m(const FMatrix4 * const m, FMatrix4 * result)
{
    Float determinant = fm4_determinant(m);

    if ( fabs(determinant) < MATH_FLOAT_EPSILON )
    {
        return;
    }

    Float scalar = 1.0f/determinant;
    FMatrix3 * subMatrix = fm3_alloc_init();
    Int sign;

    for ( Int i = 0; i < 4; i++ )
    {
        for ( Int j = 0; j < 4; j++ )
        {
            sign = 1 - ( (i + j) % 2 ) * 2;
            fm4_mss_sub_matrix_m(m,i,j,subMatrix);
            Float subMatrixDeterminant = fm3_determinant(subMatrix);
            FM_EL(*result,i,j) = subMatrixDeterminant * sign * scalar;
        }
    }

    fm3_free(subMatrix);

}

Float fm4_determinant(const FMatrix4 * const m)
{
    Float subMatrixDeterminant, determinant = 0.0f;
    FMatrix3 * subMatrix = fm3_alloc_init();
    Int scalar = 1;

    for ( Int x = 0; x < 4; x++ )
    {
        fm4_mss_sub_matrix_m(m, 0, x, subMatrix);
        subMatrixDeterminant = fm3_determinant(subMatrix);
        determinant += FM_EL(*m,x,0) * subMatrixDeterminant * scalar;
        scalar *= -1;
    }

    fm3_free(subMatrix);

    return determinant;
}

const char * fm4_m_to_string(FMatrix4 * m)
{
    char * fm4string = NULL;

    if ( asprintf(&fm4string, "%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
                  FM_EL(*m,0,0),FM_EL(*m,1,0),FM_EL(*m,2,0),FM_EL(*m,3,0),
                  FM_EL(*m,0,1),FM_EL(*m,1,1),FM_EL(*m,2,1),FM_EL(*m,3,1),
                  FM_EL(*m,0,2),FM_EL(*m,1,2),FM_EL(*m,2,2),FM_EL(*m,3,2),
                  FM_EL(*m,0,3),FM_EL(*m,1,3),FM_EL(*m,2,3),FM_EL(*m,3,3) ) < 0)
    {
        return NULL;
    }

    return fm4string;
}

