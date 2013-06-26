#define _GNU_SOURCE
#include <float.h>
#include <math.h>
#include <stdio.h>

#include "Core/Basics/NpFreeList.h"
#include "Utilities.h"
#include "Matrix.h"

NpFreeList * NP_MATRIX2_FREELIST = NULL;
NpFreeList * NP_MATRIX3_FREELIST = NULL;
NpFreeList * NP_MATRIX4_FREELIST = NULL;

void npmath_matrix_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_MATRIX2_FREELIST, Matrix2, 512)
    NPFREELIST_ALLOC_INIT(NP_MATRIX3_FREELIST, Matrix3, 512)
    NPFREELIST_ALLOC_INIT(NP_MATRIX4_FREELIST, Matrix4, 512)
}

Matrix2 * m2_alloc(void)
{
    return (Matrix2 *)npfreenode_alloc(NP_MATRIX2_FREELIST);
}

Matrix2 * m2_alloc_init(void)
{
    Matrix2 * tmp = npfreenode_alloc(NP_MATRIX2_FREELIST);
    m2_m_set_identity(tmp);

    return tmp;
}

void m2_free(Matrix2 * m)
{
    npfreenode_free(m, NP_MATRIX2_FREELIST);
}

void m2_m_set_identity(Matrix2 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = 1.0;
    M_EL(*m,0,1) = M_EL(*m,1,0) = 0.0;
}

void m2_m_transpose_m(const Matrix2 * const m, Matrix2 * transpose)
{
    M_EL(*transpose,0,0) = M_EL(*m,0,0);
    M_EL(*transpose,0,1) = M_EL(*m,1,0);

    M_EL(*transpose,1,0) = M_EL(*m,0,1);
    M_EL(*transpose,1,1) = M_EL(*m,1,1);
}

void m2_mm_add_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) + M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) + M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,1,0) + M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) + M_EL(*m2,1,1);
}

void m2_mm_subtract_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0) - M_EL(*m2,0,0);
    M_EL(*result,0,1) = M_EL(*m1,0,1) - M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,1,0) - M_EL(*m2,1,0);
    M_EL(*result,1,1) = M_EL(*m1,1,1) - M_EL(*m2,1,1);
}

void m2_mm_multiply_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result)
{
    M_EL(*result,0,0) = M_EL(*m1,0,0)*M_EL(*m2,0,0) + M_EL(*m1,1,0)*M_EL(*m2,0,1);
    M_EL(*result,0,1) = M_EL(*m1,0,1)*M_EL(*m2,0,0) + M_EL(*m1,1,1)*M_EL(*m2,0,1);
    M_EL(*result,1,0) = M_EL(*m1,0,0)*M_EL(*m2,1,0) + M_EL(*m1,1,0)*M_EL(*m2,1,1);
    M_EL(*result,1,1) = M_EL(*m1,0,1)*M_EL(*m2,1,0) + M_EL(*m1,1,1)*M_EL(*m2,1,1);
}

void m2_vm_multiply_v(const Vector2 * const v, const Matrix2 * const m, Vector2 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1);
}

void m2_mv_multiply_v(const Matrix2 * const m, const Vector2 * const v, Vector2 * result)
{
    V_X(*result) = M_EL(*m,0,0) * V_X(*v) + M_EL(*m,1,0) * V_Y(*v);
    V_Y(*result) = M_EL(*m,0,1) * V_X(*v) + M_EL(*m,1,1) * V_Y(*v);
}

void m2_m_inverse_m(const Matrix2 * const m1, Matrix2 * m2)
{
    const double determinant = m2_determinant(m1);

    if ( fabs(determinant) <= DBL_EPSILON )
    {
        return;
    }

    const double scalar = 1.0 / determinant;

    M_EL(*m2,0,0) = scalar *  M_EL(*m1,1,1);
    M_EL(*m2,0,1) = scalar * -M_EL(*m1,0,1);
    M_EL(*m2,1,0) = scalar * -M_EL(*m1,1,0);
    M_EL(*m2,1,1) = scalar *  M_EL(*m1,0,0);
}

double m2_determinant(const Matrix2 * const m)
{
    return M_EL(*m,0,0) * M_EL(*m,1,1) - M_EL(*m,0,1)*M_EL(*m,1,0);
}

Matrix2 m2_m_transposed(const Matrix2 * const m)
{
    Matrix2 transpose;
    m2_m_transpose_m(m, &transpose);
    
    return transpose;
}

Matrix2 m2_mm_add(const Matrix2 * const m1, const Matrix2 * const m2)
{
    Matrix2 result;
    m2_mm_add_m(m1, m2, &result);

    return result;
}

Matrix2 m2_mm_subtract(const Matrix2 * const m1, const Matrix2 * const m2)
{
    Matrix2 result;
    m2_mm_subtract_m(m1, m2, &result);

    return result;
}

Matrix2 m2_mm_multiply(const Matrix2 * const m1, const Matrix2 * const m2)
{
    Matrix2 result;
    m2_mm_multiply_m(m1, m2, &result);

    return result;
}

Vector2 m2_vm_multiply(const Vector2 * const v, const Matrix2 * const m)
{
    Vector2 result;
    m2_vm_multiply_v(v, m, &result);

    return result;
}

Vector2 m2_mv_multiply(const Matrix2 * const m, const Vector2 * const v)
{
    Vector2 result;
    m2_mv_multiply_v(m, v, &result);

    return result;
}

Matrix2 m2_m_inverse(const Matrix2 * const m)
{
    Matrix2 result;
    m2_m_inverse_m(m, &result);

    return result;
}

const char * m2_m_to_string(Matrix2 * m)
{
    char * m2string;

    if ( asprintf(&m2string, "%f %f\n%f %f\n",
                  M_EL(*m,0,0),M_EL(*m,1,0),
                  M_EL(*m,0,1),M_EL(*m,1,1)) < 0)
    {
        return NULL;
    }

    return m2string;
}

/* ------------------------------------------------------------------------- */

Matrix3 * m3_alloc(void)
{
    return (Matrix3 *)npfreenode_alloc(NP_MATRIX3_FREELIST);
}

Matrix3 * m3_alloc_init(void)
{
    Matrix3 * tmp = npfreenode_alloc(NP_MATRIX3_FREELIST);
    m3_m_set_identity(tmp);

    return tmp;
}

void m3_free(Matrix3 * m)
{
    npfreenode_free(m, NP_MATRIX3_FREELIST);
}

void m3_m_set_identity(Matrix3 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = M_EL(*m,2,2) = 1.0;
    M_EL(*m,0,1) = M_EL(*m,0,2) = M_EL(*m,1,0) = M_EL(*m,1,2) = M_EL(*m,2,0) = M_EL(*m,2,1) = 0.0;
}

void m3_m_transpose_m(const Matrix3 * const m, Matrix3 * transpose)
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

void m3_mm_add_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result)
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

void m3_mm_subtract_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result)
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

void m3_mm_multiply_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result)
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

void m3_vm_multiply_v(const Vector3 * const v, const Matrix3 * const m, Vector3 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1) + V_Z(*v) * M_EL(*m,0,2);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1) + V_Z(*v) * M_EL(*m,1,2);
    V_Z(*result) = V_X(*v) * M_EL(*m,2,0) + V_Y(*v) * M_EL(*m,2,1) + V_Z(*v) * M_EL(*m,2,2);
}

void m3_mv_multiply_v(const Matrix3 * const m, const Vector3 * const v, Vector3 * result)
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

void m3_m_inverse_m(const Matrix3 * const m1, Matrix3 * m2)
{
    const double determinant = m3_m_determinant(m1);

    if ( fabs(determinant) <= DBL_EPSILON )
    {
        return;
    }

    const double scalar = 1.0 / determinant;

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

void m3_m_get_right_vector_v(const Matrix3 * const m, Vector3 * right)
{
    right->x = M_EL(*m,0,0);
    right->y = M_EL(*m,1,0);
    right->z = M_EL(*m,2,0);
}

void m3_m_get_up_vector_v(const Matrix3 * const m, Vector3 * up)
{
    up->x = M_EL(*m,0,1);
    up->y = M_EL(*m,1,1);
    up->z = M_EL(*m,2,1);
}

void m3_m_get_forward_vector_v(const Matrix3 * const m, Vector3 * forward)
{
    forward->x = -M_EL(*m,0,2);
    forward->y = -M_EL(*m,1,2);
    forward->z = -M_EL(*m,2,2);
}

void m3_s_rotatex_m(double degree, Matrix3 * result)
{
    m3_m_set_identity(result);

    const double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,1,1) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,1,2) = sin(angle);
    M_EL(*result,2,1) = -M_EL(*result,1,2);
}

void m3_s_rotatey_m(double degree, Matrix3 * result)
{
    m3_m_set_identity(result);

    const double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,2,0) = sin(angle);
    M_EL(*result,0,2) = -M_EL(*result,2,0);
}

void m3_s_rotatez_m(double degree, Matrix3 * result)
{
    m3_m_set_identity(result);

    const double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,1,1) = cos(angle);
    M_EL(*result,0,1) = sin(angle);
    M_EL(*result,1,0) = -M_EL(*result,0,1);
}

void m3_s_scalex_m(double scale, Matrix3 * result)
{
    m3_m_set_identity(result);

    M_EL(*result,0,0) = scale;
}

void m3_s_scaley_m(double scale, Matrix3 * result)
{
    m3_m_set_identity(result);

    M_EL(*result,1,1) = scale;
}

void m3_s_scalez_m(double scale, Matrix3 * result)
{
    m3_m_set_identity(result);

    M_EL(*result,2,2) = scale;
}

void m3_s_scale_m(double scale, Matrix3 * result)
{
    m3_m_set_identity(result);

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

double m3_m_determinant(const Matrix3 * const m)
{
    const double EIminusHF = M_EL(*m,1,1)*M_EL(*m,2,2) - M_EL(*m,1,2)*M_EL(*m,2,1);
    const double DIminusGF = M_EL(*m,0,1)*M_EL(*m,2,2) - M_EL(*m,0,2)*M_EL(*m,2,1);
    const double DHminusGE = M_EL(*m,0,1)*M_EL(*m,1,2) - M_EL(*m,0,2)*M_EL(*m,1,1);

    return M_EL(*m,0,0) * EIminusHF - M_EL(*m,1,0) * DIminusGF + M_EL(*m,2,0) * DHminusGE;
}

Matrix3 m3_m_transposed(const Matrix3 * const m)
{
    Matrix3 transpose;
    m3_m_transpose_m(m, &transpose);

    return transpose;
}

Matrix3 m3_mm_add(const Matrix3 * const m1, const Matrix3 * const m2)
{
    Matrix3 result;
    m3_mm_add_m(m1, m2, &result);

    return result;
}

Matrix3 m3_mm_subtract(const Matrix3 * const m1, const Matrix3 * const m2)
{
    Matrix3 result;
    m3_mm_subtract_m(m1, m2, &result);

    return result;
}

Matrix3 m3_mm_multiply(const Matrix3 * const m1, const Matrix3 * const m2)
{
    Matrix3 result;
    m3_mm_multiply_m(m1, m2, &result);

    return result;
}

Vector3 m3_vm_multiply(const Vector3 * const v, const Matrix3 * const m)
{
    Vector3 result;
    m3_vm_multiply_v(v, m, &result);

    return result;
}

Vector3 m3_mv_multiply(const Matrix3 * const m, const Vector3 * const v)
{
    Vector3 result;
    m3_mv_multiply_v(m, v, &result);

    return result;
}

Matrix3 m3_m_inverse(const Matrix3 * const m)
{
    Matrix3 result;
    m3_m_inverse_m(m, &result);

    return result;
}

Vector3 m3_m_get_right_vector(const Matrix3 * const m)
{
    Vector3 right;
    m3_m_get_right_vector_v(m, &right);

    return right;
}

Vector3 m3_m_get_up_vector(const Matrix3 * const m)
{
    Vector3 up;
    m3_m_get_up_vector_v(m, &up);

    return up;
}

Vector3 m3_m_get_forward_vector(const Matrix3 * const m)
{
    Vector3 forward;
    m3_m_get_forward_vector_v(m, &forward);

    return forward;
}

Matrix3 m3_s_rotatex(double degree)
{
    Matrix3 rotate;
    m3_s_rotatex_m(degree, &rotate);

    return rotate;
}

Matrix3 m3_s_rotatey(double degree)
{
    Matrix3 rotate;
    m3_s_rotatey_m(degree, &rotate);

    return rotate;
}

Matrix3 m3_s_rotatez(double degree)
{
    Matrix3 rotate;
    m3_s_rotatez_m(degree, &rotate);

    return rotate;
}

Matrix3 m3_s_scalex(double scale)
{
    Matrix3 result;
    m3_s_scalex_m(scale, &result);

    return result;
}

Matrix3 m3_s_scaley(double scale)
{
    Matrix3 result;
    m3_s_scaley_m(scale, &result);

    return result;
}

Matrix3 m3_s_scalez(double scale)
{
    Matrix3 result;
    m3_s_scalez_m(scale, &result);

    return result;
}

Matrix3 m3_s_scale(double scale)
{
    Matrix3 result;
    m3_s_scale_m(scale, &result);

    return result;
}

const char * m3_m_to_string(Matrix3 * m)
{
    char * m3string;

    if ( asprintf(&m3string, "%f %f %f\n%f %f %f\n%f %f %f\n",
                  M_EL(*m,0,0),M_EL(*m,1,0),M_EL(*m,2,0),
                  M_EL(*m,0,1),M_EL(*m,1,1),M_EL(*m,2,1),
                  M_EL(*m,0,2),M_EL(*m,1,2),M_EL(*m,2,2)) < 0)
    {
        return NULL;
    }

    return m3string;
}

/* ------------------------------------------------------------------------- */

Matrix4 * m4_alloc(void)
{
    return (Matrix4 *)npfreenode_alloc(NP_MATRIX4_FREELIST);
}

Matrix4 * m4_alloc_init(void)
{
    Matrix4 * tmp = npfreenode_alloc(NP_MATRIX4_FREELIST);
    m4_m_set_identity(tmp);

    return tmp;
}

void m4_free(Matrix4 * m)
{
    npfreenode_free(m, NP_MATRIX4_FREELIST);
}

void m4_m_set_identity(Matrix4 * m)
{
    M_EL(*m,0,0) = M_EL(*m,1,1) = M_EL(*m,2,2) = M_EL(*m,3,3) = 1.0;
    M_EL(*m,0,1) = M_EL(*m,0,2) = M_EL(*m,0,3) = M_EL(*m,1,0) = M_EL(*m,1,2) = M_EL(*m,1,3) =
    M_EL(*m,2,0) = M_EL(*m,2,1) = M_EL(*m,2,3) = M_EL(*m,3,0) = M_EL(*m,3,1) = M_EL(*m,3,2) = 0.0;
}

void m4_m_transpose_m(const Matrix4 * const m, Matrix4 * transpose)
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

void m4_mm_add_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result)
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

void m4_mm_subtract_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result)
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

void m4_mm_multiply_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result)
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

void m4_vm_multiply_v(const Vector4 * const v, const Matrix4 * const m, Vector4 * result)
{
    V_X(*result) = V_X(*v) * M_EL(*m,0,0) + V_Y(*v) * M_EL(*m,0,1) + V_Z(*v) * M_EL(*m,0,2) + V_W(*v) * M_EL(*m,0,3);
    V_Y(*result) = V_X(*v) * M_EL(*m,1,0) + V_Y(*v) * M_EL(*m,1,1) + V_Z(*v) * M_EL(*m,1,2) + V_W(*v) * M_EL(*m,1,3);
    V_Z(*result) = V_X(*v) * M_EL(*m,2,0) + V_Y(*v) * M_EL(*m,2,1) + V_Z(*v) * M_EL(*m,2,2) + V_W(*v) * M_EL(*m,2,3);
    V_W(*result) = V_X(*v) * M_EL(*m,3,0) + V_Y(*v) * M_EL(*m,3,1) + V_Z(*v) * M_EL(*m,3,2) + V_W(*v) * M_EL(*m,3,3);
}

void m4_mv_multiply_v(const Matrix4 * const m, const Vector4 * const v, Vector4 * result)
{
    V_X(*result) = M_EL(*m,0,0) * V_X(*v) + M_EL(*m,1,0) * V_Y(*v) + M_EL(*m,2,0) * V_Z(*v) + M_EL(*m,3,0) * V_W(*v);
    V_Y(*result) = M_EL(*m,0,1) * V_X(*v) + M_EL(*m,1,1) * V_Y(*v) + M_EL(*m,2,1) * V_Z(*v) + M_EL(*m,3,1) * V_W(*v);
    V_Z(*result) = M_EL(*m,0,2) * V_X(*v) + M_EL(*m,1,2) * V_Y(*v) + M_EL(*m,2,2) * V_Z(*v) + M_EL(*m,3,2) * V_W(*v);
    V_W(*result) = M_EL(*m,0,3) * V_X(*v) + M_EL(*m,1,3) * V_Y(*v) + M_EL(*m,2,3) * V_Z(*v) + M_EL(*m,3,3) * V_W(*v);
}

void m4_mv_translation_matrix(Matrix4 * m, const Vector3 * const v)
{
    m4_m_set_identity(m);
    M_EL(*m,3,0) = V_X(*v);
    M_EL(*m,3,1) = V_Y(*v);
    M_EL(*m,3,2) = V_Z(*v);
}

void m4_mv_scale_matrix(Matrix4 * m, const Vector3 * const v)
{
    m4_m_set_identity(m);
    M_EL(*m,0,0) = v->x;
    M_EL(*m,1,1) = v->y;
    M_EL(*m,2,2) = v->z;
}

void m4_ms_scale_matrix_x(Matrix4 * m, double x)
{
    m4_m_set_identity(m);
    M_EL(*m,0,0) = x;
}

void m4_ms_scale_matrix_y(Matrix4 * m, double y)
{
    m4_m_set_identity(m);
    M_EL(*m,1,1) = y;
}

void m4_ms_scale_matrix_z(Matrix4 * m, double z)
{
    m4_m_set_identity(m);
    M_EL(*m,2,2) = z;
}

void m4_msss_scale_matrix_xyz(Matrix4 * m, double x, double y, double z)
{
    m4_m_set_identity(m);
    M_EL(*m,0,0) = x;
    M_EL(*m,1,1) = y;
    M_EL(*m,2,2) = z;
}

void m4_vvv_look_at_matrix_m(Vector3 * eyePosition, Vector3 * lookAtPosition, Vector3 * upVector, Matrix4 * result)
{
    m4_m_set_identity(result);

    Vector3 lookAtVector = v3_vv_sub(lookAtPosition, eyePosition);
    v3_v_normalise(&lookAtVector);

    Vector3 normalisedUpVector = v3_v_normalised(upVector);

    Vector3 rightVector = v3_vv_cross_product(&lookAtVector, &normalisedUpVector);
    v3_v_normalise(&rightVector);

    v3_vv_cross_product_v(&rightVector, &lookAtVector, &normalisedUpVector);
    m4_vvvv_look_at_matrix_m(&rightVector, &normalisedUpVector, &lookAtVector, eyePosition, result);
}

void m4_vvvv_look_at_matrix_m(Vector3 * rightVector, Vector3 * upVector, Vector3 * forwardVector, Vector3 * position, Matrix4 * result)
{
    Matrix4 rotation;
    m4_m_set_identity(&rotation);
    m4_m_set_identity(result);

    M_EL(rotation, 0, 0) = rightVector->x;
    M_EL(rotation, 1, 0) = rightVector->y;
    M_EL(rotation, 2, 0) = rightVector->z;

    M_EL(rotation, 0, 1) = upVector->x;
    M_EL(rotation, 1, 1) = upVector->y;
    M_EL(rotation, 2, 1) = upVector->z;

    M_EL(rotation, 0, 2) = -forwardVector->x;
    M_EL(rotation, 1, 2) = -forwardVector->y;
    M_EL(rotation, 2, 2) = -forwardVector->z;

    Vector3 inversePosition = v3_v_inverted(position);
    Matrix4 translation = m4_v_translation_matrix(&inversePosition);
    
    m4_mm_multiply_m(&rotation, &translation, result);
}

void m4_mssss_projection_matrix(Matrix4 * m, double aspectratio, double fovdegrees, double nearplane, double farplane)
{
    m4_m_set_identity(m);
    
    const double ymax = nearplane * tan(fovdegrees * MATH_PI / 360.0);
    const double ymin = -ymax;
    const double xmin = ymin * aspectratio;
    const double xmax = ymax * aspectratio;

    M_EL(*m,0,0) = (2.0 * nearplane) / (xmax - xmin);
    M_EL(*m,1,1) = (2.0 * nearplane) / (ymax - ymin);
    M_EL(*m,2,2) = -(farplane + nearplane) / (farplane - nearplane);
    M_EL(*m,3,3) = 0.0;

    M_EL(*m,2,0) = (xmax + xmin) / (xmax - xmin);
    M_EL(*m,2,1) = (ymax + ymin) / (ymax - ymin);
    M_EL(*m,2,3) = -1.0;

    M_EL(*m,3,2) = (-2.0 * farplane * nearplane) / (farplane - nearplane);
}

void m4_ms_simple_orthographic_projection_matrix(Matrix4 * m, double aspectratio)
{
    m4_m_set_identity(m);
    Vector3 tmp = { 1.0/aspectratio, 1.0, 1.0 };
    m4_mv_scale_matrix(m, &tmp);
}

void m4_mssssss_orthographic_projection_matrix(Matrix4 * m, double left, double right, double bottom, double top, double near, double far)
{
    m4_m_set_identity(m);

    M_EL(*m,0,0) =  2.0 / (right - left);
    M_EL(*m,1,1) =  2.0 / (top - bottom);
    M_EL(*m,2,2) = -2.0 / (far - near);
    M_EL(*m,3,0) = -((right + left) / (right - left));
    M_EL(*m,3,1) = -((top + bottom) / (top - bottom));
    M_EL(*m,3,2) = -((far + near) / (far - near));
    M_EL(*m,3,3) =  1.0;
}

void m4_mssss_orthographic_2d_projection_matrix(Matrix4 * m, double left, double right, double bottom, double top)
{
    m4_mssssss_orthographic_projection_matrix(m, left, right, bottom, top, -1.0, 1.0);
}

void m4_mss_sub_matrix_m(const Matrix4 * const m, int row, int column, Matrix3 * result)
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


void m4_m_inverse_m(const Matrix4 * const m, Matrix4 * result)
{
    double determinant = m4_m_determinant(m);

    if ( fabs(determinant) <= DBL_EPSILON )
    {
        return;
    }

    double scalar = 1.0/determinant;
    Matrix3 * subMatrix = m3_alloc_init();
    int sign;

    for ( int i = 0; i < 4; i++ )
    {
        for ( int j = 0; j < 4; j++ )
        {
            sign = 1 - ( (i + j) % 2 ) * 2;
            m4_mss_sub_matrix_m(m,i,j,subMatrix);
            double subMatrixDeterminant = m3_m_determinant(subMatrix);
            M_EL(*result,i,j) = sign * subMatrixDeterminant * scalar;
        }
    }

    m3_free(subMatrix);
}

void m4_m_get_right_vector_v(const Matrix4 * const m, Vector3 * right)
{
    right->x = M_EL(*m,0,0);
    right->y = M_EL(*m,1,0);
    right->z = M_EL(*m,2,0);
}

void m4_m_get_up_vector_v(const Matrix4 * const m, Vector3 * up)
{
    up->x = M_EL(*m,0,1);
    up->y = M_EL(*m,1,1);
    up->z = M_EL(*m,2,1);
}

void m4_m_get_forward_vector_v(const Matrix4 * const m, Vector3 * forward)
{
    forward->x = -M_EL(*m,0,2);
    forward->y = -M_EL(*m,1,2);
    forward->z = -M_EL(*m,2,2);
}

void m4_s_rotatex_m(double degree, Matrix4 * result)
{
    m4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,1,1) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,1,2) = sin(angle);
    M_EL(*result,2,1) = -M_EL(*result,1,2);
}

void m4_s_rotatey_m(double degree, Matrix4 * result)
{
    m4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,2,2) = cos(angle);
    M_EL(*result,2,0) = sin(angle);
    M_EL(*result,0,2) = -M_EL(*result,2,0);
}

void m4_s_rotatez_m(double degree, Matrix4 * result)
{
    m4_m_set_identity(result);

    double angle = DEGREE_TO_RADIANS(degree);

    M_EL(*result,0,0) = M_EL(*result,1,1) = cos(angle);
    M_EL(*result,0,1) = sin(angle);
    M_EL(*result,1,0) = -M_EL(*result,0,1);
}

double m4_m_determinant(const Matrix4 * const m)
{
    double subMatrixDeterminant, determinant = 0.0;
    Matrix3 * subMatrix = m3_alloc_init();
    int scalar = 1;

    for ( int x = 0; x < 4; x++ )
    {
        m4_mss_sub_matrix_m(m, 0, x, subMatrix);
        subMatrixDeterminant = m3_m_determinant(subMatrix);
        determinant += M_EL(*m,x,0) * subMatrixDeterminant * scalar;
        scalar *= -1;
    }

    m3_free(subMatrix);

    return determinant;
}

Matrix4 m4_m_transposed(const Matrix4 * const m)
{
    Matrix4 result;
    m4_m_transpose_m(m, &result);

    return result;
}

Matrix4 m4_mm_add(const Matrix4 * const m1, const Matrix4 * const m2)
{
    Matrix4 result;
    m4_mm_add_m(m1, m2, &result);

    return result;
}

Matrix4 m4_mm_subtract(const Matrix4 * const m1, const Matrix4 * const m2)
{
    Matrix4 result;
    m4_mm_subtract_m(m1, m2, &result);

    return result;
}

Matrix4 m4_mm_multiply(const Matrix4 * const m1, const Matrix4 * const m2)
{
    Matrix4 result;
    m4_mm_multiply_m(m1, m2, &result);

    return result;
}

Vector4 m4_vm_multiply(const Vector4 * const v, const Matrix4 * const m)
{
    Vector4 result;
    m4_vm_multiply_v(v, m, &result);

    return result;
}

Vector4 m4_mv_multiply(const Matrix4 * const m, const Vector4 * const v)
{
    Vector4 result;
    m4_mv_multiply_v(m, v, &result);

    return result;
}

Matrix4 m4_v_translation_matrix(const Vector3 * const v)
{
    Matrix4 result;
    m4_mv_translation_matrix(&result, v);

    return result;    
}

const char * m4_m_to_string(Matrix4 * m)
{
    char * m4string = NULL;

    if ( asprintf(&m4string, "%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
                  M_EL(*m,0,0), M_EL(*m,1,0), M_EL(*m,2,0), M_EL(*m,3,0),
                  M_EL(*m,0,1), M_EL(*m,1,1), M_EL(*m,2,1), M_EL(*m,3,1),
                  M_EL(*m,0,2), M_EL(*m,1,2), M_EL(*m,2,2), M_EL(*m,3,2),
                  M_EL(*m,0,3), M_EL(*m,1,3), M_EL(*m,2,3), M_EL(*m,3,3) ) < 0 )
    {
        return NULL;
    }

    return m4string;
}


