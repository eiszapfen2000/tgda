#include "Matrix.h"

void m2_m_set_identity(Matrix2 * m)
{
    M_E(*m,0,0) = M_E(*m,1,1) = 1.0;
    M_E(*m,0,1) = M_E(*m,1,0) = 0.0;
}

void m3_m_set_identity(Matrix3 * m)
{
    M_E(*m,0,0) = M_E(*m,1,1) = M_E(*m,2,2) = 1.0;
    M_E(*m,0,1) = M_E(*m,0,2) = M_E(*m,1,0) = M_E(*m,1,2) = M_E(*m,2,0) = M_E(*m,2,1) = 0.0;
}

void m4_m_set_identity(Matrix4 * m)
{
    M_E(*m,0,0) = M_E(*m,1,1) = M_E(*m,2,2) = M_E(*m,3,3) = 1.0;
    M_E(*m,0,1) = M_E(*m,0,2) = M_E(*m,0,3) = M_E(*m,1,0) = M_E(*m,1,2) = M_E(*m,1,3) =
    M_E(*m,2,0) = M_E(*m,2,1) = M_E(*m,2,3) = M_E(*m,3,0) = M_E(*m,3,1) = M_E(*m,3,2) = 0.0;
}

void m2_m_transpose_m(const Matrix2 * m, Matrix2 * transpose)
{
    M_E(*transpose,0,0) = M_E(*m,0,0);
    M_E(*transpose,0,1) = M_E(*m,1,0);

    M_E(*transpose,1,0) = M_E(*m,0,1);
    M_E(*transpose,1,1) = M_E(*m,1,1);
}

void m3_m_transpose_m(const Matrix3 * m, Matrix3 * transpose)
{
    M_E(*transpose,0,0) = M_E(*m,0,0);
    M_E(*transpose,0,1) = M_E(*m,1,0);
    M_E(*transpose,0,2) = M_E(*m,2,0);

    M_E(*transpose,1,0) = M_E(*m,0,1);
    M_E(*transpose,1,1) = M_E(*m,1,1);
    M_E(*transpose,1,2) = M_E(*m,2,1);

    M_E(*transpose,2,0) = M_E(*m,0,2);
    M_E(*transpose,2,1) = M_E(*m,1,2);
    M_E(*transpose,2,2) = M_E(*m,2,2);
}

void m4_m_transpose_m(const Matrix4 * m, Matrix4 * transpose)
{
    M_E(*transpose,0,0) = M_E(*m,0,0);
    M_E(*transpose,0,1) = M_E(*m,1,0);
    M_E(*transpose,0,2) = M_E(*m,2,0);
    M_E(*transpose,0,3) = M_E(*m,3,0);

    M_E(*transpose,1,0) = M_E(*m,0,1);
    M_E(*transpose,1,1) = M_E(*m,1,1);
    M_E(*transpose,1,2) = M_E(*m,2,1);
    M_E(*transpose,1,3) = M_E(*m,3,1);

    M_E(*transpose,2,0) = M_E(*m,0,2);
    M_E(*transpose,2,1) = M_E(*m,1,2);
    M_E(*transpose,2,2) = M_E(*m,2,2);
    M_E(*transpose,2,3) = M_E(*m,3,2);

    M_E(*transpose,3,0) = M_E(*m,0,3);
    M_E(*transpose,3,1) = M_E(*m,1,3);
    M_E(*transpose,3,2) = M_E(*m,2,3);
    M_E(*transpose,3,3) = M_E(*m,3,3);
}

void m2_mm_add_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) + M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) + M_E(*m2,0,1);
    M_E(*result,1,0) = M_E(*m1,1,0) + M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) + M_E(*m2,1,1);
}

void m3_mm_add_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) + M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) + M_E(*m2,0,1);
    M_E(*result,0,2) = M_E(*m1,0,2) + M_E(*m2,0,2);

    M_E(*result,1,0) = M_E(*m1,1,0) + M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) + M_E(*m2,1,1);
    M_E(*result,1,2) = M_E(*m1,1,2) + M_E(*m2,1,2);

    M_E(*result,2,0) = M_E(*m1,2,0) + M_E(*m2,2,0);
    M_E(*result,2,1) = M_E(*m1,2,1) + M_E(*m2,2,1);
    M_E(*result,2,2) = M_E(*m1,2,2) + M_E(*m2,2,2);
}
void m4_mm_add_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) + M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) + M_E(*m2,0,1);
    M_E(*result,0,2) = M_E(*m1,0,2) + M_E(*m2,0,2);
    M_E(*result,0,3) = M_E(*m1,0,3) + M_E(*m2,0,3);

    M_E(*result,1,0) = M_E(*m1,1,0) + M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) + M_E(*m2,1,1);
    M_E(*result,1,2) = M_E(*m1,1,2) + M_E(*m2,1,2);
    M_E(*result,1,3) = M_E(*m1,1,3) + M_E(*m2,1,3);

    M_E(*result,2,0) = M_E(*m1,2,0) + M_E(*m2,2,0);
    M_E(*result,2,1) = M_E(*m1,2,1) + M_E(*m2,2,1);
    M_E(*result,2,2) = M_E(*m1,2,2) + M_E(*m2,2,2);
    M_E(*result,2,3) = M_E(*m1,2,3) + M_E(*m2,2,3);

    M_E(*result,3,0) = M_E(*m1,3,0) + M_E(*m2,3,0);
    M_E(*result,3,1) = M_E(*m1,3,1) + M_E(*m2,3,1);
    M_E(*result,3,2) = M_E(*m1,3,2) + M_E(*m2,3,2);
    M_E(*result,3,3) = M_E(*m1,3,3) + M_E(*m2,3,3);
}

void m2_mm_subtract_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) - M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) - M_E(*m2,0,1);
    M_E(*result,1,0) = M_E(*m1,1,0) - M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) - M_E(*m2,1,1);
}

void m3_mm_subtract_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) - M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) - M_E(*m2,0,1);
    M_E(*result,0,2) = M_E(*m1,0,2) - M_E(*m2,0,2);

    M_E(*result,1,0) = M_E(*m1,1,0) - M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) - M_E(*m2,1,1);
    M_E(*result,1,2) = M_E(*m1,1,2) - M_E(*m2,1,2);

    M_E(*result,2,0) = M_E(*m1,2,0) - M_E(*m2,2,0);
    M_E(*result,2,1) = M_E(*m1,2,1) - M_E(*m2,2,1);
    M_E(*result,2,2) = M_E(*m1,2,2) - M_E(*m2,2,2);
}
void m4_mm_subtract_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0) - M_E(*m2,0,0);
    M_E(*result,0,1) = M_E(*m1,0,1) - M_E(*m2,0,1);
    M_E(*result,0,2) = M_E(*m1,0,2) - M_E(*m2,0,2);
    M_E(*result,0,3) = M_E(*m1,0,3) - M_E(*m2,0,3);

    M_E(*result,1,0) = M_E(*m1,1,0) - M_E(*m2,1,0);
    M_E(*result,1,1) = M_E(*m1,1,1) - M_E(*m2,1,1);
    M_E(*result,1,2) = M_E(*m1,1,2) - M_E(*m2,1,2);
    M_E(*result,1,3) = M_E(*m1,1,3) - M_E(*m2,1,3);

    M_E(*result,2,0) = M_E(*m1,2,0) - M_E(*m2,2,0);
    M_E(*result,2,1) = M_E(*m1,2,1) - M_E(*m2,2,1);
    M_E(*result,2,2) = M_E(*m1,2,2) - M_E(*m2,2,2);
    M_E(*result,2,3) = M_E(*m1,2,3) - M_E(*m2,2,3);

    M_E(*result,3,0) = M_E(*m1,3,0) - M_E(*m2,3,0);
    M_E(*result,3,1) = M_E(*m1,3,1) - M_E(*m2,3,1);
    M_E(*result,3,2) = M_E(*m1,3,2) - M_E(*m2,3,2);
    M_E(*result,3,3) = M_E(*m1,3,3) - M_E(*m2,3,3);
}

void m2_mm_multiply_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0)*M_E(*m2,0,0) + M_E(*m1,1,0)*M_E(*m2,0,1);
    M_E(*result,0,1) = M_E(*m1,0,1)*M_E(*m2,0,0) + M_E(*m1,1,1)*M_E(*m2,0,1);
    M_E(*result,1,0) = M_E(*m1,0,0)*M_E(*m2,1,0) + M_E(*m1,1,0)*M_E(*m2,1,1);
    M_E(*result,1,1) = M_E(*m1,0,1)*M_E(*m2,1,0) + M_E(*m1,1,1)*M_E(*m2,1,1);
}

void m3_mm_multiply_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0)*M_E(*m2,0,0) + M_E(*m1,1,0)*M_E(*m2,0,1) + M_E(*m1,2,0)*M_E(*m2,0,2);
    M_E(*result,1,0) = M_E(*m1,0,0)*M_E(*m2,1,0) + M_E(*m1,1,0)*M_E(*m2,1,1) + M_E(*m1,2,0)*M_E(*m2,1,2);
    M_E(*result,2,0) = M_E(*m1,0,0)*M_E(*m2,2,0) + M_E(*m1,1,0)*M_E(*m2,2,1) + M_E(*m1,2,0)*M_E(*m2,2,2);

    M_E(*result,0,1) = M_E(*m1,0,1)*M_E(*m2,0,0) + M_E(*m1,1,1)*M_E(*m2,0,1) + M_E(*m1,2,1)*M_E(*m2,0,2);
    M_E(*result,1,1) = M_E(*m1,0,1)*M_E(*m2,1,0) + M_E(*m1,1,1)*M_E(*m2,1,1) + M_E(*m1,2,1)*M_E(*m2,1,2);
    M_E(*result,2,1) = M_E(*m1,0,1)*M_E(*m2,2,0) + M_E(*m1,1,1)*M_E(*m2,2,1) + M_E(*m1,2,1)*M_E(*m2,2,2);

    M_E(*result,0,2) = M_E(*m1,0,2)*M_E(*m2,0,0) + M_E(*m1,1,2)*M_E(*m2,0,1) + M_E(*m1,2,2)*M_E(*m2,0,2);
    M_E(*result,1,2) = M_E(*m1,0,2)*M_E(*m2,1,0) + M_E(*m1,1,2)*M_E(*m2,1,1) + M_E(*m1,2,2)*M_E(*m2,1,2);
    M_E(*result,2,2) = M_E(*m1,0,2)*M_E(*m2,2,0) + M_E(*m1,1,2)*M_E(*m2,2,1) + M_E(*m1,2,2)*M_E(*m2,2,2);
}

void m4_mm_multiply_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result)
{
    M_E(*result,0,0) = M_E(*m1,0,0)*M_E(*m2,0,0) + M_E(*m1,1,0)*M_E(*m2,0,1) + M_E(*m1,2,0)*M_E(*m2,0,2) + M_E(*m1,3,0)*M_E(*m2,0,3);
    M_E(*result,1,0) = M_E(*m1,0,0)*M_E(*m2,1,0) + M_E(*m1,1,0)*M_E(*m2,1,1) + M_E(*m1,2,0)*M_E(*m2,1,2) + M_E(*m1,3,0)*M_E(*m2,1,3);
    M_E(*result,2,0) = M_E(*m1,0,0)*M_E(*m2,2,0) + M_E(*m1,1,0)*M_E(*m2,2,1) + M_E(*m1,2,0)*M_E(*m2,2,2) + M_E(*m1,3,0)*M_E(*m2,2,3);
    M_E(*result,3,0) = M_E(*m1,0,0)*M_E(*m2,3,0) + M_E(*m1,1,0)*M_E(*m2,3,1) + M_E(*m1,2,0)*M_E(*m2,3,2) + M_E(*m1,3,0)*M_E(*m2,3,3);

    M_E(*result,0,1) = M_E(*m1,0,1)*M_E(*m2,0,0) + M_E(*m1,1,1)*M_E(*m2,0,1) + M_E(*m1,2,1)*M_E(*m2,0,2) + M_E(*m1,3,1)*M_E(*m2,0,3);
    M_E(*result,1,1) = M_E(*m1,0,1)*M_E(*m2,1,0) + M_E(*m1,1,1)*M_E(*m2,1,1) + M_E(*m1,2,1)*M_E(*m2,1,2) + M_E(*m1,3,1)*M_E(*m2,1,3);
    M_E(*result,2,1) = M_E(*m1,0,1)*M_E(*m2,2,0) + M_E(*m1,1,1)*M_E(*m2,2,1) + M_E(*m1,2,1)*M_E(*m2,2,2) + M_E(*m1,3,1)*M_E(*m2,2,3);
    M_E(*result,3,1) = M_E(*m1,0,1)*M_E(*m2,3,0) + M_E(*m1,1,1)*M_E(*m2,3,1) + M_E(*m1,2,1)*M_E(*m2,3,2) + M_E(*m1,3,1)*M_E(*m2,3,3);

    M_E(*result,0,2) = M_E(*m1,0,2)*M_E(*m2,0,0) + M_E(*m1,1,2)*M_E(*m2,0,1) + M_E(*m1,2,2)*M_E(*m2,0,2) + M_E(*m1,3,2)*M_E(*m2,0,3);
    M_E(*result,1,2) = M_E(*m1,0,2)*M_E(*m2,1,0) + M_E(*m1,1,2)*M_E(*m2,1,1) + M_E(*m1,2,2)*M_E(*m2,1,2) + M_E(*m1,3,2)*M_E(*m2,1,3);
    M_E(*result,2,2) = M_E(*m1,0,2)*M_E(*m2,2,0) + M_E(*m1,1,2)*M_E(*m2,2,1) + M_E(*m1,2,2)*M_E(*m2,2,2) + M_E(*m1,3,2)*M_E(*m2,2,3);
    M_E(*result,3,2) = M_E(*m1,0,2)*M_E(*m2,3,0) + M_E(*m1,1,2)*M_E(*m2,3,1) + M_E(*m1,2,2)*M_E(*m2,3,2) + M_E(*m1,3,2)*M_E(*m2,3,3);

    M_E(*result,0,3) = M_E(*m1,0,3)*M_E(*m2,0,0) + M_E(*m1,1,3)*M_E(*m2,0,1) + M_E(*m1,2,3)*M_E(*m2,0,2) + M_E(*m1,3,3)*M_E(*m2,0,3);
    M_E(*result,1,3) = M_E(*m1,0,3)*M_E(*m2,1,0) + M_E(*m1,1,3)*M_E(*m2,1,1) + M_E(*m1,2,3)*M_E(*m2,1,2) + M_E(*m1,3,3)*M_E(*m2,1,3);
    M_E(*result,2,3) = M_E(*m1,0,3)*M_E(*m2,2,0) + M_E(*m1,1,3)*M_E(*m2,2,1) + M_E(*m1,2,3)*M_E(*m2,2,2) + M_E(*m1,3,3)*M_E(*m2,2,3);
    M_E(*result,3,3) = M_E(*m1,0,3)*M_E(*m2,3,0) + M_E(*m1,1,3)*M_E(*m2,3,1) + M_E(*m1,2,3)*M_E(*m2,3,2) + M_E(*m1,3,3)*M_E(*m2,3,3);
}

void m2_vm_multiply_v(Vector2 * v, Matrix2 * m, Vector2 * result)
{
    V_X(*result) = V_X(*v) * M_E(*m,0,0) + V_Y(*v) * M_E(*m,0,1);
    V_Y(*result) = V_X(*v) * M_E(*m,1,0) + V_Y(*v) * M_E(*m,1,1);
}

void m3_vm_multiply_v(Vector3 * v, Matrix3 * m, Vector3 * result)
{
    V_X(*result) = V_X(*v) * M_E(*m,0,0) + V_Y(*v) * M_E(*m,0,1) + V_Z(*v) * M_E(*m,0,2);
    V_Y(*result) = V_X(*v) * M_E(*m,1,0) + V_Y(*v) * M_E(*m,1,1) + V_Z(*v) * M_E(*m,1,2);
    V_Z(*result) = V_X(*v) * M_E(*m,2,0) + V_Y(*v) * M_E(*m,2,1) + V_Z(*v) * M_E(*m,2,2);
}

void m4_vm_multiply_v(Vector4 * v, Matrix4 * m, Vector4 * result)
{
    V_X(*result) = V_X(*v) * M_E(*m,0,0) + V_Y(*v) * M_E(*m,0,1) + V_Z(*v) * M_E(*m,0,2) + V_W(*v) * M_E(*m,0,3);
    V_Y(*result) = V_X(*v) * M_E(*m,1,0) + V_Y(*v) * M_E(*m,1,1) + V_Z(*v) * M_E(*m,1,2) + V_W(*v) * M_E(*m,1,3);
    V_Z(*result) = V_X(*v) * M_E(*m,2,0) + V_Y(*v) * M_E(*m,2,1) + V_Z(*v) * M_E(*m,2,2) + V_W(*v) * M_E(*m,2,3);
    V_W(*result) = V_X(*v) * M_E(*m,3,0) + V_Y(*v) * M_E(*m,3,1) + V_Z(*v) * M_E(*m,3,2) + V_W(*v) * M_E(*m,3,3);
}

void m2_mv_multiply_v(Matrix2 * m, Vector2 * v, Vector2 * result)
{
    V_X(*result) = M_E(*m,0,0) * V_X(*v) + M_E(*m,1,0) * V_Y(*v);
    V_Y(*result) = M_E(*m,0,1) * V_X(*v) + M_E(*m,1,1) * V_Y(*v);
}

void m3_mv_multiply_v(Matrix3 * m, Vector3 * v, Vector3 * result)
{
    V_X(*result) = M_E(*m,0,0) * V_X(*v) + M_E(*m,1,0) * V_Y(*v) + M_E(*m,2,0) * V_Z(*v);
    V_Y(*result) = M_E(*m,0,1) * V_X(*v) + M_E(*m,1,1) * V_Y(*v) + M_E(*m,2,1) * V_Z(*v);
    V_Z(*result) = M_E(*m,0,2) * V_X(*v) + M_E(*m,1,2) * V_Y(*v) + M_E(*m,2,2) * V_Z(*v);
}

void m4_mv_multiply_v(Matrix4 * m, Vector4 * v, Vector4 * result)
{
    V_X(*result) = M_E(*m,0,0) * V_X(*v) + M_E(*m,1,0) * V_Y(*v) + M_E(*m,2,0) * V_Z(*v) + M_E(*m,3,0) * V_W(*v);
    V_Y(*result) = M_E(*m,0,1) * V_X(*v) + M_E(*m,1,1) * V_Y(*v) + M_E(*m,2,1) * V_Z(*v) + M_E(*m,3,1) * V_W(*v);
    V_Z(*result) = M_E(*m,0,2) * V_X(*v) + M_E(*m,1,2) * V_Y(*v) + M_E(*m,2,2) * V_Z(*v) + M_E(*m,3,2) * V_W(*v);
    V_W(*result) = M_E(*m,0,3) * V_X(*v) + M_E(*m,1,3) * V_Y(*v) + M_E(*m,2,3) * V_Z(*v) + M_E(*m,3,3) * V_W(*v);
}
