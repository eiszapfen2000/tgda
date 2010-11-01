#include "Core/Basics/NpFreeList.h"
#include "Matrix.h"

NpFreeList * NP_MATRIX2_FREELIST = NULL;
NpFreeList * NP_MATRIX3_FREELIST = NULL;
NpFreeList * NP_MATRIX4_FREELIST = NULL;

void npmath_matrix_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_MATRIX2_FREELIST, Matrix2, 512)
    NPFREELIST_ALLOC_INIT(NP_MATRIX3_FREELIST, Matrix3, 512)
    NPFREELIST_ALLOC_INIT(NP_MATRIX4_FREELIST, Matrix4, 512)
}

Matrix2 * m2_alloc()
{
    return (Matrix2 *)npfreenode_alloc(NP_MATRIX2_FREELIST);
}

Matrix2 * m2_alloc_init()
{
    Matrix2 * tmp = npfreenode_alloc(NP_MATRIX2_FREELIST);
    m2_set_identity(tmp);

    return tmp;
}

Matrix2 * m2_free(Matrix2 * m)
{
    return npfreenode_free(m, NP_MATRIX2_FREELIST);
}

void m2_set_identity(Matrix2 * m)
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

Matrix3 * m3_alloc()
{
    return (Matrix3 *)npfreenode_alloc(NP_MATRIX3_FREELIST);
}

Matrix3 * m3_alloc_init()
{
    Matrix3 * tmp = npfreenode_alloc(NP_MATRIX3_FREELIST);
    m3_set_identity(tmp);

    return tmp;
}

Matrix3 * m3_free(Matrix3 * m)
{
    return npfreenode_free(m, NP_MATRIX3_FREELIST);
}

void m3_set_identity(Matrix3 * m)
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

Matrix4 * m4_alloc()
{
    return (Matrix4 *)npfreenode_alloc(NP_MATRIX4_FREELIST);
}

Matrix4 * m4_alloc_init()
{
    Matrix4 * tmp = npfreenode_alloc(NP_MATRIX4_FREELIST);
    m4_set_identity(tmp);

    return tmp;
}

Matrix4 * m4_free(Matrix4 * m)
{
    return npfreenode_free(m, NP_MATRIX4_FREELIST);
}

void m4_set_identity(Matrix4 * m)
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

