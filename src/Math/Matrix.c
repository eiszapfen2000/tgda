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
