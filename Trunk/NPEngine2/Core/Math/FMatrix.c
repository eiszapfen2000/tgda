#define _GNU_SOURCE
#include <float.h>
#include <math.h>
#include <stdio.h>

#include "Core/Basics/NpFreeList.h"
#include "Utilities.h"
#include "Matrix.h"
#include "FMatrix.h"

NpFreeList * NP_FMATRIX2_FREELIST = NULL;
NpFreeList * NP_FMATRIX3_FREELIST = NULL;
NpFreeList * NP_FMATRIX4_FREELIST = NULL;

void npmath_fmatrix_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FMATRIX2_FREELIST, FMatrix2, 512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX3_FREELIST, FMatrix3, 512)
    NPFREELIST_ALLOC_INIT(NP_FMATRIX4_FREELIST, FMatrix4, 512)
}

FMatrix2 * fm2_alloc(void)
{
    return (FMatrix2 *)npfreenode_alloc(NP_FMATRIX2_FREELIST);
}

FMatrix2 * fm2_alloc_init(void)
{
    FMatrix2 * tmp = npfreenode_alloc(NP_FMATRIX2_FREELIST);
    fm2_m_set_identity(tmp);

    return tmp;
}

void fm2_free(FMatrix2 * v)
{
    npfreenode_free(v, NP_FMATRIX2_FREELIST);
}

void fm2_m_set_identity(FMatrix2 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = 1.0f;
    M_EL(*m,0,1) = M_EL(*m,1,0) = 0.0f;
}

void fm2_m_init_with_m2(FMatrix2 * m1, const struct Matrix2 * const m2)
{
    M_EL(*m1,0,0) = M_EL(*m2,0,0);
    M_EL(*m1,0,1) = M_EL(*m2,0,1);
    M_EL(*m1,1,0) = M_EL(*m2,1,0);
    M_EL(*m1,1,1) = M_EL(*m2,1,1);
}

void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose)
{
    M_EL(*transpose,0,0) = M_EL(*m,0,0);
    M_EL(*transpose,0,1) = M_EL(*m,1,0);

    M_EL(*transpose,1,0) = M_EL(*m,0,1);
    M_EL(*transpose,1,1) = M_EL(*m,1,1);
}

void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) + M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) + M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,1,0) + M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) + M_EL(*m2,1,1);
}

void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) - M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) - M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,1,0) - M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) - M_EL(*m2,1,1);
}

void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0)*M_EL(*m2,0,0) + M_EL(*m1,1,0)*M_EL(*m2,0,1);
    M_EL(*result,0,1) = M_EL(*m1,0,1)*M_EL(*m2,0,0) + M_EL(*m1,1,1)*M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,0,0)*M_EL(*m2,1,0) + M_EL(*m1,1,0)*M_EL(*m2,1,1);
    M_EL(*result,1,1) = M_EL(*m1,0,1)*M_EL(*m2,1,0) + M_EL(*m1,1,1)*M_EL(*m2,1,1);
}

void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1);
}

void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result)
{
    V_X(*result) = M_EL(*m,0,0) * V_X(*v) + M_EL(*m,1,0) * V_Y(*v);
    V_Y(*result) = M_EL(*m,0,1) * V_X(*v) + M_EL(*m,1,1) * V_Y(*v);
}

void fm2_m_inverse_m(const FMatrix2 * const m1, FMatrix2 * m2)
{
    const float determinant = fm2_determinant(m1);

    if ( fabsf(determinant) <= FLT_EPSILON )
    {
        return;
    }

    const float scalar = 1.0f / determinant;

    M_EL(*m2,0,0) = scalar *  M_EL(*m1,1,1);
    M_EL(*m2,0,1) = scalar * -M_EL(*m1,0,1);
    M_EL(*m2,1,0) = scalar * -M_EL(*m1,1,0);
    M_EL(*m2,1,1) = scalar *  M_EL(*m1,0,0);
}

float fm2_determinant(const FMatrix2 * const m)
{
    return M_EL(*m,0,0) * M_EL(*m,1,1) - M_EL(*m,0,1)*M_EL(*m,1,0);
}

FMatrix2 fm2_m_transposed(const FMatrix2 * const m)
{
    FMatrix2 transpose;
    fm2_m_transpose_m(m, &transpose);
    
    return transpose;
}

FMatrix2 fm2_mm_add(const FMatrix2 * const m1, const FMatrix2 * const m2)
{
    FMatrix2 result;
    fm2_mm_add_m(m1, m2, &result);

    return result;
}

FMatrix2 fm2_mm_subtract(const FMatrix2 * const m1, const FMatrix2 * const m2)
{
    FMatrix2 result;
    fm2_mm_subtract_m(m1, m2, &result);

    return result;
}

FMatrix2 fm2_mm_multiply(const FMatrix2 * const m1, const FMatrix2 * const m2)
{
    FMatrix2 result;
    fm2_mm_multiply_m(m1, m2, &result);

    return result;
}

FVector2 fm2_vm_multiply(const FVector2 * const v, const FMatrix2 * const m)
{
    FVector2 result;
    fm2_vm_multiply_v(v, m, &result);

    return result;
}

FVector2 fm2_mv_multiply(const FMatrix2 * const m, const FVector2 * const v)
{
    FVector2 result;
    fm2_mv_multiply_v(m, v, &result);

    return result;
}

FMatrix2 fm2_m_inverse(const FMatrix2 * const m)
{
    FMatrix2 result;
    fm2_m_inverse_m(m, &result);

    return result;
}

const char * fm2_m_to_string(FMatrix2 * m)
{
    char * fm2string;

    if ( asprintf(&fm2string, "%f %f\n%f %f\n",
                  M_EL(*m,0,0),M_EL(*m,1,0),
                  M_EL(*m,0,1),M_EL(*m,1,1)) < 0)
    {
        return NULL;
    }

    return fm2string;
}

//-----------------------------------------------------------------------------

FMatrix3 * fm3_alloc(void)
{
    return (FMatrix3 *)npfreenode_alloc(NP_FMATRIX3_FREELIST);
}

FMatrix3 * fm3_alloc_init(void)
{
    FMatrix3 * tmp = npfreenode_alloc(NP_FMATRIX3_FREELIST);
    fm3_m_set_identity(tmp);

    return tmp;
}

void fm3_free(FMatrix3 * v)
{
    npfreenode_free(v, NP_FMATRIX3_FREELIST);
}

void fm3_m_set_identity(FMatrix3 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = M_EL(*m,2,2) = 1.0;
    M_EL(*m,0,1) = M_EL(*m,0,2) = M_EL(*m,1,0) = M_EL(*m,1,2) = M_EL(*m,2,0) = M_EL(*m,2,1) = 0.0;
}

void fm3_m_init_with_m3(FMatrix3 * m1, const struct Matrix3 * const m2)
{
    for ( uint32_t i = 0; i < 3; i++ )
    {
        for ( uint32_t j = 0; j < 3; j++ )
        {
            M_EL(*m1, i, j) = M_EL(*m2, i, j);
        }
    }
}

void fm3_m_transpose_m(const FMatrix3 * const m, FMatrix3 * transpose)
{
    M_EL(*transpose,0,0) = M_EL(*m,0,0);
    M_EL(*transpose,0,1) = M_EL(*m,1,0);
    M_EL(*transpose,0,2) = M_EL(*m,2,0);

    M_EL(*transpose,1,0) = M_EL(*m,0,1);
    M_EL(*transpose,1,1) = M_EL(*m,1,1);
    M_EL(*transpose,1,2) = M_EL(*m,2,1);

    M_EL(*transpose,2,0) = M_EL(*m,0,2);
    M_EL(*transpose,2,1) = M_EL(*m,1,2);
    M_EL(*transpose,2,2) = M_EL(*m,2,2);
}

void fm3_mm_add_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) + M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) + M_EL(*m2,0,1);
    M_EL(*result,0,2) = M_EL(*m1,0,2) + M_EL(*m2,0,2);

    M_EL(*result,1,0) = M_EL(*m1,1,0) + M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) + M_EL(*m2,1,1);
    M_EL(*result,1,2) = M_EL(*m1,1,2) + M_EL(*m2,1,2);

    M_EL(*result,2,0) = M_EL(*m1,2,0) + M_EL(*m2,2,0);
    M_EL(*result,2,1) = M_EL(*m1,2,1) + M_EL(*m2,2,1);
    M_EL(*result,2,2) = M_EL(*m1,2,2) + M_EL(*m2,2,2);
}

void fm3_mm_subtract_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) - M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) - M_EL(*m2,0,1);
    M_EL(*result,0,2) = M_EL(*m1,0,2) - M_EL(*m2,0,2);

    M_EL(*result,1,0) = M_EL(*m1,1,0) - M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) - M_EL(*m2,1,1);
    M_EL(*result,1,2) = M_EL(*m1,1,2) - M_EL(*m2,1,2);

    M_EL(*result,2,0) = M_EL(*m1,2,0) - M_EL(*m2,2,0);
    M_EL(*result,2,1) = M_EL(*m1,2,1) - M_EL(*m2,2,1);
    M_EL(*result,2,2) = M_EL(*m1,2,2) - M_EL(*m2,2,2);
}

void fm3_mm_multiply_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0)*M_EL(*m2,0,0) + M_EL(*m1,1,0)*M_EL(*m2,0,1) + M_EL(*m1,2,0)*M_EL(*m2,0,2);
    M_EL(*result,1,0) = M_EL(*m1,0,0)*M_EL(*m2,1,0) + M_EL(*m1,1,0)*M_EL(*m2,1,1) + M_EL(*m1,2,0)*M_EL(*m2,1,2);
    M_EL(*result,2,0) = M_EL(*m1,0,0)*M_EL(*m2,2,0) + M_EL(*m1,1,0)*M_EL(*m2,2,1) + M_EL(*m1,2,0)*M_EL(*m2,2,2);

    M_EL(*result,0,1) = M_EL(*m1,0,1)*M_EL(*m2,0,0) + M_EL(*m1,1,1)*M_EL(*m2,0,1) + M_EL(*m1,2,1)*M_EL(*m2,0,2);
    M_EL(*result,1,1) = M_EL(*m1,0,1)*M_EL(*m2,1,0) + M_EL(*m1,1,1)*M_EL(*m2,1,1) + M_EL(*m1,2,1)*M_EL(*m2,1,2);
    M_EL(*result,2,1) = M_EL(*m1,0,1)*M_EL(*m2,2,0) + M_EL(*m1,1,1)*M_EL(*m2,2,1) + M_EL(*m1,2,1)*M_EL(*m2,2,2);

    M_EL(*result,0,2) = M_EL(*m1,0,2)*M_EL(*m2,0,0) + M_EL(*m1,1,2)*M_EL(*m2,0,1) + M_EL(*m1,2,2)*M_EL(*m2,0,2);
    M_EL(*result,1,2) = M_EL(*m1,0,2)*M_EL(*m2,1,0) + M_EL(*m1,1,2)*M_EL(*m2,1,1) + M_EL(*m1,2,2)*M_EL(*m2,1,2);
    M_EL(*result,2,2) = M_EL(*m1,0,2)*M_EL(*m2,2,0) + M_EL(*m1,1,2)*M_EL(*m2,2,1) + M_EL(*m1,2,2)*M_EL(*m2,2,2);
}

void fm3_vm_multiply_v(const FVector3 * const v, const FMatrix3 * const m, FVector3 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1) + V_Z(*v) * M_EL(*m,0,2);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1) + V_Z(*v) * M_EL(*m,1,2);
    V_Z(*result) = V_X(*v) * M_EL(*m,2,0) + V_Y(*v) * M_EL(*m,2,1) + V_Z(*v) * M_EL(*m,2,2);
}

void fm3_mv_multiply_v(const FMatrix3 * const m, const FVector3 * const v, FVector3 * result)
{
    V_X(*result) = M_EL(*m,0,0) * V_X(*v) + M_EL(*m,1,0) * V_Y(*v) + M_EL(*m,2,0) * V_Z(*v);
    V_Y(*result) = M_EL(*m,0,1) * V_X(*v) + M_EL(*m,1,1) * V_Y(*v) + M_EL(*m,2,1) * V_Z(*v);
    V_Z(*result) = M_EL(*m,0,2) * V_X(*v) + M_EL(*m,1,2) * V_Y(*v) + M_EL(*m,2,2) * V_Z(*v);
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
    const float determinant = fm3_m_determinant(m1);

    if ( fabsf(determinant) <= FLT_EPSILON )
    {
        return;
    }

    const float scalar = 1.0f / determinant;

    M_EL(*m2,0,0) = scalar *   ( M_EL(*m1,1,1)*M_EL(*m1,2,2) - M_EL(*m1,2,1)*M_EL(*m1,1,2) );
    M_EL(*m2,0,1) = scalar * (-( M_EL(*m1,0,1)*M_EL(*m1,2,2) - M_EL(*m1,2,1)*M_EL(*m1,0,2) ));
    M_EL(*m2,0,2) = scalar *   ( M_EL(*m1,0,1)*M_EL(*m1,1,2) - M_EL(*m1,0,2)*M_EL(*m1,1,1) );

    M_EL(*m2,1,0) = scalar * (-( M_EL(*m1,1,0)*M_EL(*m1,2,2) - M_EL(*m1,1,2)*M_EL(*m1,2,0) ));
    M_EL(*m2,1,1) = scalar *   ( M_EL(*m1,0,0)*M_EL(*m1,2,2) - M_EL(*m1,0,2)*M_EL(*m1,2,0) );
    M_EL(*m2,1,2) = scalar * (-( M_EL(*m1,0,0)*M_EL(*m1,1,2) - M_EL(*m1,0,2)*M_EL(*m1,1,0) ));

    M_EL(*m2,2,0) = scalar *   ( M_EL(*m1,1,0)*M_EL(*m1,2,1) - M_EL(*m1,1,1)*M_EL(*m1,2,0) );
    M_EL(*m2,2,1) = scalar * (-( M_EL(*m1,0,0)*M_EL(*m1,2,1) - M_EL(*m1,0,1)*M_EL(*m1,2,0) ));
    M_EL(*m2,2,2) = scalar *   ( M_EL(*m1,0,0)*M_EL(*m1,1,1) - M_EL(*m1,1,0)*M_EL(*m1,0,1) );
}

void fm3_m_get_right_vector_v(const FMatrix3 * const m, FVector3 * right)
{
    right->x = M_EL(*m,0,0);
    right->y = M_EL(*m,1,0);
    right->z = M_EL(*m,2,0);
}

void fm3_m_get_up_vector_v(const FMatrix3 * const m, FVector3 * up)
{
    up->x = M_EL(*m,0,1);
    up->y = M_EL(*m,1,1);
    up->z = M_EL(*m,2,1);
}

void fm3_m_get_forward_vector_v(const FMatrix3 * const m, FVector3 * forward)
{
    forward->x = -M_EL(*m,0,2);
    forward->y = -M_EL(*m,1,2);
    forward->z = -M_EL(*m,2,2);
}

void fm3_s_rotatex_m(float degree, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,1,1) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,1,2) = sin(angle);
    M_EL(*result,2,1) = -M_EL(*result,1,2);
}

void fm3_s_rotatey_m(float degree, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,2,0) = sin(angle);
    M_EL(*result,0,2) = -M_EL(*result,2,0);
}

void fm3_s_rotatez_m(float degree, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,1,1) = cos(angle);
    M_EL(*result,0,1) = sin(angle);
    M_EL(*result,1,0) = -M_EL(*result,0,1);
}

void fm3_s_scalex_m(float scale, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    M_EL(*result,0,0) = scale;
}

void fm3_s_scaley_m(float scale, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    M_EL(*result,1,1) = scale;
}

void fm3_s_scalez_m(float scale, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    M_EL(*result,2,2) = scale;
}

void fm3_s_scale_m(float scale, FMatrix3 * result)
{
    fm3_m_set_identity(result);

    M_EL(*result,0,0) = scale;
    M_EL(*result,1,1) = scale;
    M_EL(*result,2,2) = scale;
}

/*
  If Kramer's rule is applied to a matrix M:

        | A B C |
    M = | D E F |
        | G H I |

  then the determinant is calculated as follows:

    det M = A * (EI - HF) - B * (DI - GF) + C * (DH - GE)
*/

float fm3_m_determinant(const FMatrix3 * const m)
{
    float EIminusHF = M_EL(*m,1,1)*M_EL(*m,2,2) - M_EL(*m,1,2)*M_EL(*m,2,1);
    float DIminusGF = M_EL(*m,0,1)*M_EL(*m,2,2) - M_EL(*m,0,2)*M_EL(*m,2,1);
    float DHminusGE = M_EL(*m,0,1)*M_EL(*m,1,2) - M_EL(*m,0,2)*M_EL(*m,1,1);

    return M_EL(*m,0,0) * EIminusHF - M_EL(*m,1,0) * DIminusGF + M_EL(*m,2,0) * DHminusGE;
}

FMatrix3 fm3_m_transposed(const FMatrix3 * const m)
{
    FMatrix3 transpose;
    fm3_m_transpose_m(m, &transpose);

    return transpose;
}

FMatrix3 fm3_mm_add(const FMatrix3 * const m1, const FMatrix3 * const m2)
{
    FMatrix3 result;
    fm3_mm_add_m(m1, m2, &result);

    return result;
}

FMatrix3 fm3_mm_subtract(const FMatrix3 * const m1, const FMatrix3 * const m2)
{
    FMatrix3 result;
    fm3_mm_subtract_m(m1, m2, &result);

    return result;
}

FMatrix3 fm3_mm_multiply(const FMatrix3 * const m1, const FMatrix3 * const m2)
{
    FMatrix3 result;
    fm3_mm_multiply_m(m1, m2, &result);

    return result;
}

FVector3 fm3_vm_multiply(const FVector3 * const v, const FMatrix3 * const m)
{
    FVector3 result;
    fm3_vm_multiply_v(v, m, &result);

    return result;
}

FVector3 fm3_mv_multiply(const FMatrix3 * const m, const FVector3 * const v)
{
    FVector3 result;
    fm3_mv_multiply_v(m, v, &result);

    return result;
}

FMatrix3 fm3_m_inverse(const FMatrix3 * const m)
{
    FMatrix3 result;
    fm3_m_inverse_m(m, &result);

    return result;
}

FVector3 fm3_m_get_right_vector(const FMatrix3 * const m)
{
    FVector3 right;
    fm3_m_get_right_vector_v(m, &right);

    return right;
}

FVector3 fm3_m_get_up_vector(const FMatrix3 * const m)
{
    FVector3 up;
    fm3_m_get_up_vector_v(m, &up);

    return up;
}

FVector3 fm3_m_get_forward_vector(const FMatrix3 * const m)
{
    FVector3 forward;
    fm3_m_get_forward_vector_v(m, &forward);

    return forward;
}

FMatrix3 fm3_s_rotatex(float degree)
{
    FMatrix3 rotate;
    fm3_s_rotatex_m(degree, &rotate);

    return rotate;
}

FMatrix3 fm3_s_rotatey(float degree)
{
    FMatrix3 rotate;
    fm3_s_rotatey_m(degree, &rotate);

    return rotate;
}

FMatrix3 fm3_s_rotatez(float degree)
{
    FMatrix3 rotate;
    fm3_s_rotatez_m(degree, &rotate);

    return rotate;
}

FMatrix3 fm3_s_scalex(float scale)
{
    FMatrix3 result;
    fm3_s_scalex_m(scale, &result);

    return result;
}

FMatrix3 fm3_s_scaley(float scale)
{
    FMatrix3 result;
    fm3_s_scaley_m(scale, &result);

    return result;
}

FMatrix3 fm3_s_scalez(float scale)
{
    FMatrix3 result;
    fm3_s_scalez_m(scale, &result);

    return result;
}

FMatrix3 fm3_s_scale(float scale)
{
    FMatrix3 result;
    fm3_s_scale_m(scale, &result);

    return result;
}

const char * fm3_m_to_string(FMatrix3 * m)
{
    char * fm3string;

    if ( asprintf(&fm3string, "%f %f %f\n%f %f %f\n%f %f %f\n",
                  M_EL(*m,0,0),M_EL(*m,1,0),M_EL(*m,2,0),
                  M_EL(*m,0,1),M_EL(*m,1,1),M_EL(*m,2,1),
                  M_EL(*m,0,2),M_EL(*m,1,2),M_EL(*m,2,2)) < 0)
    {
        return NULL;
    }

    return fm3string;
}

/* ------------------------------------------------------------------------- */

FMatrix4 * fm4_alloc(void)
{
    return (FMatrix4 *)npfreenode_alloc(NP_FMATRIX4_FREELIST);
}

FMatrix4 * fm4_alloc_init(void)
{
    FMatrix4 * tmp = npfreenode_alloc(NP_FMATRIX4_FREELIST);
    fm4_m_set_identity(tmp);

    return tmp;
}

FMatrix4 * fm4_alloc_init_with_fm4(FMatrix4 * m)
{
    FMatrix4 * tmp = npfreenode_alloc(NP_FMATRIX4_FREELIST);
    *tmp = *m;

    return tmp;
}

void fm4_free(FMatrix4 * v)
{
    npfreenode_free(v,NP_FMATRIX4_FREELIST);
}

void fm4_m_set_identity(FMatrix4 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = M_EL(*m,2,2) = M_EL(*m,3,3) = 1.0;
    M_EL(*m,0,1) = M_EL(*m,0,2) = M_EL(*m,0,3) = M_EL(*m,1,0) = M_EL(*m,1,2) = M_EL(*m,1,3) =
    M_EL(*m,2,0) = M_EL(*m,2,1) = M_EL(*m,2,3) = M_EL(*m,3,0) = M_EL(*m,3,1) = M_EL(*m,3,2) = 0.0;
}

void fm4_m_init_with_m4(FMatrix4 * m1, const struct Matrix4 * const m2)
{
    for ( uint32_t i = 0; i < 4; i++ )
    {
        for ( uint32_t j = 0; j < 4; j++ )
        {
            M_EL(*m1, i, j) = M_EL(*m2, i, j);
        }
    }
}

void fm4_m_init_with_fm4(FMatrix4 * destination, FMatrix4 * source)
{
    *destination = *source;
}

void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose)
{
    M_EL(*transpose,0,0) = M_EL(*m,0,0);
    M_EL(*transpose,0,1) = M_EL(*m,1,0);
    M_EL(*transpose,0,2) = M_EL(*m,2,0);
    M_EL(*transpose,0,3) = M_EL(*m,3,0);

    M_EL(*transpose,1,0) = M_EL(*m,0,1);
    M_EL(*transpose,1,1) = M_EL(*m,1,1);
    M_EL(*transpose,1,2) = M_EL(*m,2,1);
    M_EL(*transpose,1,3) = M_EL(*m,3,1);

    M_EL(*transpose,2,0) = M_EL(*m,0,2);
    M_EL(*transpose,2,1) = M_EL(*m,1,2);
    M_EL(*transpose,2,2) = M_EL(*m,2,2);
    M_EL(*transpose,2,3) = M_EL(*m,3,2);

    M_EL(*transpose,3,0) = M_EL(*m,0,3);
    M_EL(*transpose,3,1) = M_EL(*m,1,3);
    M_EL(*transpose,3,2) = M_EL(*m,2,3);
    M_EL(*transpose,3,3) = M_EL(*m,3,3);
}

void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) + M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) + M_EL(*m2,0,1);
    M_EL(*result,0,2) = M_EL(*m1,0,2) + M_EL(*m2,0,2);
    M_EL(*result,0,3) = M_EL(*m1,0,3) + M_EL(*m2,0,3);

    M_EL(*result,1,0) = M_EL(*m1,1,0) + M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) + M_EL(*m2,1,1);
    M_EL(*result,1,2) = M_EL(*m1,1,2) + M_EL(*m2,1,2);
    M_EL(*result,1,3) = M_EL(*m1,1,3) + M_EL(*m2,1,3);

    M_EL(*result,2,0) = M_EL(*m1,2,0) + M_EL(*m2,2,0);
    M_EL(*result,2,1) = M_EL(*m1,2,1) + M_EL(*m2,2,1);
    M_EL(*result,2,2) = M_EL(*m1,2,2) + M_EL(*m2,2,2);
    M_EL(*result,2,3) = M_EL(*m1,2,3) + M_EL(*m2,2,3);

    M_EL(*result,3,0) = M_EL(*m1,3,0) + M_EL(*m2,3,0);
    M_EL(*result,3,1) = M_EL(*m1,3,1) + M_EL(*m2,3,1);
    M_EL(*result,3,2) = M_EL(*m1,3,2) + M_EL(*m2,3,2);
    M_EL(*result,3,3) = M_EL(*m1,3,3) + M_EL(*m2,3,3);
}

void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) - M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) - M_EL(*m2,0,1);
    M_EL(*result,0,2) = M_EL(*m1,0,2) - M_EL(*m2,0,2);
    M_EL(*result,0,3) = M_EL(*m1,0,3) - M_EL(*m2,0,3);

    M_EL(*result,1,0) = M_EL(*m1,1,0) - M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) - M_EL(*m2,1,1);
    M_EL(*result,1,2) = M_EL(*m1,1,2) - M_EL(*m2,1,2);
    M_EL(*result,1,3) = M_EL(*m1,1,3) - M_EL(*m2,1,3);

    M_EL(*result,2,0) = M_EL(*m1,2,0) - M_EL(*m2,2,0);
    M_EL(*result,2,1) = M_EL(*m1,2,1) - M_EL(*m2,2,1);
    M_EL(*result,2,2) = M_EL(*m1,2,2) - M_EL(*m2,2,2);
    M_EL(*result,2,3) = M_EL(*m1,2,3) - M_EL(*m2,2,3);

    M_EL(*result,3,0) = M_EL(*m1,3,0) - M_EL(*m2,3,0);
    M_EL(*result,3,1) = M_EL(*m1,3,1) - M_EL(*m2,3,1);
    M_EL(*result,3,2) = M_EL(*m1,3,2) - M_EL(*m2,3,2);
    M_EL(*result,3,3) = M_EL(*m1,3,3) - M_EL(*m2,3,3);
}

void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0)*M_EL(*m2,0,0) + M_EL(*m1,1,0)*M_EL(*m2,0,1) + M_EL(*m1,2,0)*M_EL(*m2,0,2) + M_EL(*m1,3,0)*M_EL(*m2,0,3);
    M_EL(*result,1,0) = M_EL(*m1,0,0)*M_EL(*m2,1,0) + M_EL(*m1,1,0)*M_EL(*m2,1,1) + M_EL(*m1,2,0)*M_EL(*m2,1,2) + M_EL(*m1,3,0)*M_EL(*m2,1,3);
    M_EL(*result,2,0) = M_EL(*m1,0,0)*M_EL(*m2,2,0) + M_EL(*m1,1,0)*M_EL(*m2,2,1) + M_EL(*m1,2,0)*M_EL(*m2,2,2) + M_EL(*m1,3,0)*M_EL(*m2,2,3);
    M_EL(*result,3,0) = M_EL(*m1,0,0)*M_EL(*m2,3,0) + M_EL(*m1,1,0)*M_EL(*m2,3,1) + M_EL(*m1,2,0)*M_EL(*m2,3,2) + M_EL(*m1,3,0)*M_EL(*m2,3,3);

    M_EL(*result,0,1) = M_EL(*m1,0,1)*M_EL(*m2,0,0) + M_EL(*m1,1,1)*M_EL(*m2,0,1) + M_EL(*m1,2,1)*M_EL(*m2,0,2) + M_EL(*m1,3,1)*M_EL(*m2,0,3);
    M_EL(*result,1,1) = M_EL(*m1,0,1)*M_EL(*m2,1,0) + M_EL(*m1,1,1)*M_EL(*m2,1,1) + M_EL(*m1,2,1)*M_EL(*m2,1,2) + M_EL(*m1,3,1)*M_EL(*m2,1,3);
    M_EL(*result,2,1) = M_EL(*m1,0,1)*M_EL(*m2,2,0) + M_EL(*m1,1,1)*M_EL(*m2,2,1) + M_EL(*m1,2,1)*M_EL(*m2,2,2) + M_EL(*m1,3,1)*M_EL(*m2,2,3);
    M_EL(*result,3,1) = M_EL(*m1,0,1)*M_EL(*m2,3,0) + M_EL(*m1,1,1)*M_EL(*m2,3,1) + M_EL(*m1,2,1)*M_EL(*m2,3,2) + M_EL(*m1,3,1)*M_EL(*m2,3,3);

    M_EL(*result,0,2) = M_EL(*m1,0,2)*M_EL(*m2,0,0) + M_EL(*m1,1,2)*M_EL(*m2,0,1) + M_EL(*m1,2,2)*M_EL(*m2,0,2) + M_EL(*m1,3,2)*M_EL(*m2,0,3);
    M_EL(*result,1,2) = M_EL(*m1,0,2)*M_EL(*m2,1,0) + M_EL(*m1,1,2)*M_EL(*m2,1,1) + M_EL(*m1,2,2)*M_EL(*m2,1,2) + M_EL(*m1,3,2)*M_EL(*m2,1,3);
    M_EL(*result,2,2) = M_EL(*m1,0,2)*M_EL(*m2,2,0) + M_EL(*m1,1,2)*M_EL(*m2,2,1) + M_EL(*m1,2,2)*M_EL(*m2,2,2) + M_EL(*m1,3,2)*M_EL(*m2,2,3);
    M_EL(*result,3,2) = M_EL(*m1,0,2)*M_EL(*m2,3,0) + M_EL(*m1,1,2)*M_EL(*m2,3,1) + M_EL(*m1,2,2)*M_EL(*m2,3,2) + M_EL(*m1,3,2)*M_EL(*m2,3,3);

    M_EL(*result,0,3) = M_EL(*m1,0,3)*M_EL(*m2,0,0) + M_EL(*m1,1,3)*M_EL(*m2,0,1) + M_EL(*m1,2,3)*M_EL(*m2,0,2) + M_EL(*m1,3,3)*M_EL(*m2,0,3);
    M_EL(*result,1,3) = M_EL(*m1,0,3)*M_EL(*m2,1,0) + M_EL(*m1,1,3)*M_EL(*m2,1,1) + M_EL(*m1,2,3)*M_EL(*m2,1,2) + M_EL(*m1,3,3)*M_EL(*m2,1,3);
    M_EL(*result,2,3) = M_EL(*m1,0,3)*M_EL(*m2,2,0) + M_EL(*m1,1,3)*M_EL(*m2,2,1) + M_EL(*m1,2,3)*M_EL(*m2,2,2) + M_EL(*m1,3,3)*M_EL(*m2,2,3);
    M_EL(*result,3,3) = M_EL(*m1,0,3)*M_EL(*m2,3,0) + M_EL(*m1,1,3)*M_EL(*m2,3,1) + M_EL(*m1,2,3)*M_EL(*m2,3,2) + M_EL(*m1,3,3)*M_EL(*m2,3,3);
}

void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1) + V_Z(*v) * M_EL(*m,0,2) + V_W(*v) * M_EL(*m,0,3);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1) + V_Z(*v) * M_EL(*m,1,2) + V_W(*v) * M_EL(*m,1,3);
    V_Z(*result) = V_X(*v) * M_EL(*m,2,0) + V_Y(*v) * M_EL(*m,2,1) + V_Z(*v) * M_EL(*m,2,2) + V_W(*v) * M_EL(*m,2,3);
    V_W(*result) = V_X(*v) * M_EL(*m,3,0) + V_Y(*v) * M_EL(*m,3,1) + V_Z(*v) * M_EL(*m,3,2) + V_W(*v) * M_EL(*m,3,3);
}

void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result)
{
    V_X(*result) = M_EL(*m,0,0) * V_X(*v) + M_EL(*m,1,0) * V_Y(*v) + M_EL(*m,2,0) * V_Z(*v) + M_EL(*m,3,0) * V_W(*v);
    V_Y(*result) = M_EL(*m,0,1) * V_X(*v) + M_EL(*m,1,1) * V_Y(*v) + M_EL(*m,2,1) * V_Z(*v) + M_EL(*m,3,1) * V_W(*v);
    V_Z(*result) = M_EL(*m,0,2) * V_X(*v) + M_EL(*m,1,2) * V_Y(*v) + M_EL(*m,2,2) * V_Z(*v) + M_EL(*m,3,2) * V_W(*v);
    V_W(*result) = M_EL(*m,0,3) * V_X(*v) + M_EL(*m,1,3) * V_Y(*v) + M_EL(*m,2,3) * V_Z(*v) + M_EL(*m,3,3) * V_W(*v);
}

void fm4_mv_translation_matrix(FMatrix4 * m, const FVector3 * const v)
{
    fm4_m_set_identity(m);
    M_EL(*m,3,0) = V_X(*v);
    M_EL(*m,3,1) = V_Y(*v);
    M_EL(*m,3,2) = V_Z(*v);
}

void fm4_mv_scale_matrix(FMatrix4 * m, const FVector3 * const v)
{
    fm4_m_set_identity(m);
    M_EL(*m,0,0) = v->x;
    M_EL(*m,1,1) = v->y;
    M_EL(*m,2,2) = v->z;
}

void fm4_ms_scale_matrix_x(FMatrix4 * m, float x)
{
    fm4_m_set_identity(m);
    M_EL(*m,0,0) = x;
}

void fm4_ms_scale_matrix_y(FMatrix4 * m, float y)
{
    fm4_m_set_identity(m);
    M_EL(*m,1,1) = y;
}

void fm4_ms_scale_matrix_z(FMatrix4 * m, float z)
{
    fm4_m_set_identity(m);
    M_EL(*m,2,2) = z;
}

void fm4_msss_scale_matrix_xyz(FMatrix4 * m, float x, float y, float z)
{
    fm4_m_set_identity(m);
    M_EL(*m,0,0) = x;
    M_EL(*m,1,1) = y;
    M_EL(*m,2,2) = z;
}

void fm4_vvv_look_at_matrix_m(const FVector3 * const eyePosition, const FVector3 * const lookAtPosition, const FVector3 * const upVector, FMatrix4 * result)
{
    fm4_m_set_identity(result);

    FVector3 lookAtVector = fv3_vv_sub(lookAtPosition, eyePosition);
    fv3_v_normalise(&lookAtVector);

    FVector3 normalisedUpVector = fv3_v_normalised(upVector);

    FVector3 rightVector = fv3_vv_cross_product(&lookAtVector, &normalisedUpVector);
    fv3_v_normalise(&rightVector);

    fv3_vv_cross_product_v(&rightVector, &lookAtVector, &normalisedUpVector);
    fm4_vvvv_look_at_matrix_m(&rightVector, &normalisedUpVector, &lookAtVector, eyePosition, result);
}

void fm4_vvvv_look_at_matrix_m(const FVector3 * const rightVector, const FVector3 * const upVector, const FVector3 * const forwardVector, const FVector3 * const position, FMatrix4 * result)
{
    FMatrix4 rotation;
    fm4_m_set_identity(&rotation);
    fm4_m_set_identity(result);

    M_EL(rotation, 0, 0) = rightVector->x;
    M_EL(rotation, 1, 0) = rightVector->y;
    M_EL(rotation, 2, 0) = rightVector->z;

    M_EL(rotation, 0, 1) = upVector->x;
    M_EL(rotation, 1, 1) = upVector->y;
    M_EL(rotation, 2, 1) = upVector->z;

    M_EL(rotation, 0, 2) = -forwardVector->x;
    M_EL(rotation, 1, 2) = -forwardVector->y;
    M_EL(rotation, 2, 2) = -forwardVector->z;

    FVector3 inversePosition = fv3_v_inverted(position);
    FMatrix4 translation = fm4_v_translation_matrix(&inversePosition);
    
    fm4_mm_multiply_m(&rotation, &translation, result);
}

void fm4_mssss_projection_matrix(FMatrix4 * m, float aspectratio, float fovdegrees, float nearplane, float farplane)
{
    fm4_m_set_identity(m);
    
    const double ymax = nearplane * tan(fovdegrees * MATH_PI / 360.0);
    const double ymin = -ymax;
    const double xmin = ymin * aspectratio;
    const double xmax = ymax * aspectratio;

    M_EL(*m,0,0) = (2.0 * nearplane) / (xmax - xmin);
    M_EL(*m,1,1) = (2.0 * nearplane) / (ymax - ymin);
    M_EL(*m,2,2) = -(farplane + nearplane) / (farplane - nearplane);
    M_EL(*m,3,3) = 0.0f;

    M_EL(*m,2,0) = (xmax + xmin) / (xmax - xmin);
    M_EL(*m,2,1) = (ymax + ymin) / (ymax - ymin);
    M_EL(*m,2,3) = -1.0f;

    M_EL(*m,3,2) = (-2.0f * farplane * nearplane) / (farplane - nearplane);
}

void fm4_ms_simple_orthographic_projection_matrix(FMatrix4 * m, float aspectratio)
{
    fm4_m_set_identity(m);
    FVector3 tmp = { 1.0f/aspectratio, 1.0f, 1.0f };
    fm4_mv_scale_matrix(m, &tmp);
}

void fm4_mssssss_orthographic_projection_matrix(FMatrix4 * m, float left, float right, float bottom, float top, float near, float far)
{
    fm4_m_set_identity(m);

    M_EL(*m,0,0) =  2.0f / (right - left);
    M_EL(*m,1,1) =  2.0f / (top - bottom);
    M_EL(*m,2,2) = -2.0f / (far - near);
    M_EL(*m,3,0) = -((right + left) / (right - left));
    M_EL(*m,3,1) = -((top + bottom) / (top - bottom));
    M_EL(*m,3,2) = -((far + near) / (far - near));
    M_EL(*m,3,3) =  1.0f;
}

void fm4_mssss_orthographic_2d_projection_matrix(FMatrix4 * m, float left, float right, float bottom, float top)
{
    fm4_mssssss_orthographic_projection_matrix(m, left, right, bottom, top, -1.0f, 1.0f);
}

void fm4_mss_sub_matrix_m(const FMatrix4 * const m, int row, int column, FMatrix3 * result)
{
    int columnIndex = 0;
    int rowIndex = 0;

    for ( int i = 0; i < 4; i++ )
    {
        if ( i == column )
        {
            continue;
        }

        for ( int j = 0; j < 4; j++ )
        {
            if ( j == row )
            {
                continue;
            }

            M_EL(*result,columnIndex,rowIndex) = M_EL(*m,i,j);
            rowIndex++;
        }

        columnIndex++;
        rowIndex = 0;
    }
}


void fm4_m_inverse_m(const FMatrix4 * const m, FMatrix4 * result)
{
    float determinant = fm4_m_determinant(m);

    if ( fabsf(determinant) <= FLT_EPSILON )
    {
        return;
    }

    float scalar = 1.0f/determinant;
    FMatrix3 subMatrix;
    int sign;

    for ( int i = 0; i < 4; i++ )
    {
        for ( int j = 0; j < 4; j++ )
        {
            sign = 1 - ( (i + j) % 2 ) * 2;
            fm4_mss_sub_matrix_m(m, i, j, &subMatrix);
            float subMatrixDeterminant = fm3_m_determinant(&subMatrix);
            M_EL(*result,i,j) = sign * subMatrixDeterminant * scalar;
        }
    }
}

void fm4_m_get_right_vector_v(const FMatrix4 * const m, FVector3 * right)
{
    right->x = M_EL(*m,0,0);
    right->y = M_EL(*m,1,0);
    right->z = M_EL(*m,2,0);
}

void fm4_m_get_up_vector_v(const FMatrix4 * const m, FVector3 * up)
{
    up->x = M_EL(*m,0,1);
    up->y = M_EL(*m,1,1);
    up->z = M_EL(*m,2,1);
}

void fm4_m_get_forward_vector_v(const FMatrix4 * const m, FVector3 * forward)
{
    forward->x = -M_EL(*m,0,2);
    forward->y = -M_EL(*m,1,2);
    forward->z = -M_EL(*m,2,2);
}

void fm4_s_rotatex_m(float degree, FMatrix4 * result)
{
    fm4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,1,1) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,1,2) = sin(angle);
    M_EL(*result,2,1) = -M_EL(*result,1,2);
}

void fm4_s_rotatey_m(float degree, FMatrix4 * result)
{
    fm4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,2,0) = sin(angle);
    M_EL(*result,0,2) = -M_EL(*result,2,0);
}

void fm4_s_rotatez_m(float degree, FMatrix4 * result)
{
    fm4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,1,1) = cos(angle);
    M_EL(*result,0,1) = sin(angle);
    M_EL(*result,1,0) = -M_EL(*result,0,1);
}

float fm4_m_determinant(const FMatrix4 * const m)
{
    float subMatrixDeterminant, determinant = 0.0f;
    FMatrix3 subMatrix;
    int scalar = 1;

    for ( int x = 0; x < 4; x++ )
    {
        fm4_mss_sub_matrix_m(m, 0, x, &subMatrix);
        subMatrixDeterminant = fm3_m_determinant(&subMatrix);
        determinant += M_EL(*m,x,0) * subMatrixDeterminant * scalar;
        scalar *= -1;
    }

    return determinant;
}

FMatrix4 fm4_m_transposed(const FMatrix4 * const m)
{
    FMatrix4 result;
    fm4_m_transpose_m(m, &result);

    return result;
}

FMatrix4 fm4_mm_add(const FMatrix4 * const m1, const FMatrix4 * const m2)
{
    FMatrix4 result;
    fm4_mm_add_m(m1, m2, &result);

    return result;
}

FMatrix4 fm4_mm_subtract(const FMatrix4 * const m1, const FMatrix4 * const m2)
{
    FMatrix4 result;
    fm4_mm_subtract_m(m1, m2, &result);

    return result;
}

FMatrix4 fm4_mm_multiply(const FMatrix4 * const m1, const FMatrix4 * const m2)
{
    FMatrix4 result;
    fm4_mm_multiply_m(m1, m2, &result);

    return result;
}

FVector4 fm4_vm_multiply(const FVector4 * const v, const FMatrix4 * const m)
{
    FVector4 result;
    fm4_vm_multiply_v(v, m, &result);

    return result;
}

FVector4 fm4_mv_multiply(const FMatrix4 * const m, const FVector4 * const v)
{
    FVector4 result;
    fm4_mv_multiply_v(m, v, &result);

    return result;
}

FMatrix4 fm4_v_translation_matrix(const FVector3 * const v)
{
    FMatrix4 result;
    fm4_mv_translation_matrix(&result, v);

    return result;    
}

const char * fm4_m_to_string(FMatrix4 * m)
{
    char * fm4string = NULL;

    if ( asprintf(&fm4string, "%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
                  M_EL(*m,0,0), M_EL(*m,1,0), M_EL(*m,2,0), M_EL(*m,3,0),
                  M_EL(*m,0,1), M_EL(*m,1,1), M_EL(*m,2,1), M_EL(*m,3,1),
                  M_EL(*m,0,2), M_EL(*m,1,2), M_EL(*m,2,2), M_EL(*m,3,2),
                  M_EL(*m,0,3), M_EL(*m,1,3), M_EL(*m,2,3), M_EL(*m,3,3) ) < 0 )
    {
        return NULL;
    }

    return fm4string;
}

