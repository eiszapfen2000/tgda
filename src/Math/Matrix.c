#include "Matrix.h"

void m2_mm_multiply_m(Matrix2 * m1, Matrix2 * m2, Matrix2 * result)
{
    M_ELEMENT(*result,0,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,0,1);
    M_ELEMENT(*result,0,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,0,1);
    M_ELEMENT(*result,1,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,1,1);
    M_ELEMENT(*result,1,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,1,1);
}

void m3_mm_multiply_m(Matrix3 * m1, Matrix3 * m2, Matrix3 * result)
{
    M_ELEMENT(*result,0,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,0,2);
    M_ELEMENT(*result,1,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,1,2);
    M_ELEMENT(*result,2,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,2,2);

    M_ELEMENT(*result,0,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,0,2);
    M_ELEMENT(*result,1,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,1,2);
    M_ELEMENT(*result,2,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,2,2);

    M_ELEMENT(*result,0,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,0,2);
    M_ELEMENT(*result,1,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,1,2);
    M_ELEMENT(*result,2,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,2,2);
}

void m4_mm_multiply_m(Matrix4 * m1, Matrix4 * m2, Matrix4 * result)
{
    M_ELEMENT(*result,0,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,0,2)
                            + M_ELEMENT(*m1,3,0)*M_ELEMENT(*m2,0,3);

    M_ELEMENT(*result,1,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,1,2)
                            + M_ELEMENT(*m1,3,0)*M_ELEMENT(*m2,1,3);

    M_ELEMENT(*result,2,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,2,2)
                            + M_ELEMENT(*m1,3,0)*M_ELEMENT(*m2,2,3);

    M_ELEMENT(*result,3,0) = M_ELEMENT(*m1,0,0)*M_ELEMENT(*m2,3,0) + M_ELEMENT(*m1,1,0)*M_ELEMENT(*m2,3,1) + M_ELEMENT(*m1,2,0)*M_ELEMENT(*m2,3,2)
                            + M_ELEMENT(*m1,3,0)*M_ELEMENT(*m2,3,3);

    M_ELEMENT(*result,0,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,0,2)
                            + M_ELEMENT(*m1,3,1)*M_ELEMENT(*m2,0,3);

    M_ELEMENT(*result,1,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,1,2)
                            + M_ELEMENT(*m1,3,1)*M_ELEMENT(*m2,1,3);

    M_ELEMENT(*result,2,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,2,2)
                            + M_ELEMENT(*m1,3,1)*M_ELEMENT(*m2,2,3);

    M_ELEMENT(*result,3,1) = M_ELEMENT(*m1,0,1)*M_ELEMENT(*m2,3,0) + M_ELEMENT(*m1,1,1)*M_ELEMENT(*m2,3,1) + M_ELEMENT(*m1,2,1)*M_ELEMENT(*m2,3,2)
                            + M_ELEMENT(*m1,3,1)*M_ELEMENT(*m2,3,3);

    M_ELEMENT(*result,0,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,0,2)
                            + M_ELEMENT(*m1,3,2)*M_ELEMENT(*m2,0,3);

    M_ELEMENT(*result,1,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,1,2)
                            + M_ELEMENT(*m1,3,2)*M_ELEMENT(*m2,1,3);

    M_ELEMENT(*result,2,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,2,2)
                            + M_ELEMENT(*m1,3,2)*M_ELEMENT(*m2,2,3);

    M_ELEMENT(*result,3,2) = M_ELEMENT(*m1,0,2)*M_ELEMENT(*m2,3,0) + M_ELEMENT(*m1,1,2)*M_ELEMENT(*m2,3,1) + M_ELEMENT(*m1,2,2)*M_ELEMENT(*m2,3,2)
                            + M_ELEMENT(*m1,3,2)*M_ELEMENT(*m2,3,3);

    M_ELEMENT(*result,0,3) = M_ELEMENT(*m1,0,3)*M_ELEMENT(*m2,0,0) + M_ELEMENT(*m1,1,3)*M_ELEMENT(*m2,0,1) + M_ELEMENT(*m1,2,3)*M_ELEMENT(*m2,0,2)
                            + M_ELEMENT(*m1,3,3)*M_ELEMENT(*m2,0,3);

    M_ELEMENT(*result,1,3) = M_ELEMENT(*m1,0,3)*M_ELEMENT(*m2,1,0) + M_ELEMENT(*m1,1,3)*M_ELEMENT(*m2,1,1) + M_ELEMENT(*m1,2,3)*M_ELEMENT(*m2,1,2)
                            + M_ELEMENT(*m1,3,3)*M_ELEMENT(*m2,1,3);

    M_ELEMENT(*result,2,3) = M_ELEMENT(*m1,0,3)*M_ELEMENT(*m2,2,0) + M_ELEMENT(*m1,1,3)*M_ELEMENT(*m2,2,1) + M_ELEMENT(*m1,2,3)*M_ELEMENT(*m2,2,2)
                            + M_ELEMENT(*m1,3,3)*M_ELEMENT(*m2,2,3);

    M_ELEMENT(*result,3,3) = M_ELEMENT(*m1,0,3)*M_ELEMENT(*m2,3,0) + M_ELEMENT(*m1,1,3)*M_ELEMENT(*m2,3,1) + M_ELEMENT(*m1,2,3)*M_ELEMENT(*m2,3,2)
                            + M_ELEMENT(*m1,3,3)*M_ELEMENT(*m2,3,3);
}
