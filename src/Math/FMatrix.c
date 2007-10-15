#include "FMatrix.h"

void fm2_m_set_identity(FMatrix2 * m)
{
    FM_E(*m,0,0) = FM_E(*m,1,1) = 1.0;
    FM_E(*m,0,1) = FM_E(*m,1,0) = 0.0;
}

void fm3_m_set_identity(FMatrix3 * m)
{
    FM_E(*m,0,0) = FM_E(*m,1,1) = FM_E(*m,2,2) = 1.0;
    FM_E(*m,0,1) = FM_E(*m,0,2) = FM_E(*m,1,0) = FM_E(*m,1,2) = FM_E(*m,2,0) = FM_E(*m,2,1) = 0.0;
}

void fm4_m_set_identity(FMatrix4 * m)
{
    FM_E(*m,0,0) = FM_E(*m,1,1) = FM_E(*m,2,2) = FM_E(*m,3,3) = 1.0;
    FM_E(*m,0,1) = FM_E(*m,0,2) = FM_E(*m,0,3) = FM_E(*m,1,0) = FM_E(*m,1,2) = FM_E(*m,1,3) =
    FM_E(*m,2,0) = FM_E(*m,2,1) = FM_E(*m,2,3) = FM_E(*m,3,0) = FM_E(*m,3,1) = FM_E(*m,3,2) = 0.0;
}

void fm2_m_transpose_m(FMatrix2 * m, FMatrix2 * transpose)
{
    FM_E(*transpose,0,0) = FM_E(*m,0,0);
    FM_E(*transpose,0,1) = FM_E(*m,1,0);

    FM_E(*transpose,1,0) = FM_E(*m,0,1);
    FM_E(*transpose,1,1) = FM_E(*m,1,1);
}

void fm3_m_transpose_m(FMatrix3 * m, FMatrix3 * transpose)
{
    FM_E(*transpose,0,0) = FM_E(*m,0,0);
    FM_E(*transpose,0,1) = FM_E(*m,1,0);
    FM_E(*transpose,0,2) = FM_E(*m,2,0);

    FM_E(*transpose,1,0) = FM_E(*m,0,1);
    FM_E(*transpose,1,1) = FM_E(*m,1,1);
    FM_E(*transpose,1,2) = FM_E(*m,2,1);

    FM_E(*transpose,2,0) = FM_E(*m,0,2);
    FM_E(*transpose,2,1) = FM_E(*m,1,2);
    FM_E(*transpose,2,2) = FM_E(*m,2,2);
}

void fm4_m_transpose_m(FMatrix4 * m, FMatrix4 * transpose)
{
    FM_E(*transpose,0,0) = FM_E(*m,0,0);
    FM_E(*transpose,0,1) = FM_E(*m,1,0);
    FM_E(*transpose,0,2) = FM_E(*m,2,0);
    FM_E(*transpose,0,3) = FM_E(*m,3,0);

    FM_E(*transpose,1,0) = FM_E(*m,0,1);
    FM_E(*transpose,1,1) = FM_E(*m,1,1);
    FM_E(*transpose,1,2) = FM_E(*m,2,1);
    FM_E(*transpose,1,3) = FM_E(*m,3,1);

    FM_E(*transpose,2,0) = FM_E(*m,0,2);
    FM_E(*transpose,2,1) = FM_E(*m,1,2);
    FM_E(*transpose,2,2) = FM_E(*m,2,2);
    FM_E(*transpose,2,3) = FM_E(*m,3,2);

    FM_E(*transpose,3,0) = FM_E(*m,0,3);
    FM_E(*transpose,3,1) = FM_E(*m,1,3);
    FM_E(*transpose,3,2) = FM_E(*m,2,3);
    FM_E(*transpose,3,3) = FM_E(*m,3,3);
}


void fm2_mm_multiply_m(FMatrix2 * m1, FMatrix2 * m2, FMatrix2 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0)*FM_E(*m2,0,0) + FM_E(*m1,1,0)*FM_E(*m2,0,1);
    FM_E(*result,0,1) = FM_E(*m1,0,1)*FM_E(*m2,0,0) + FM_E(*m1,1,1)*FM_E(*m2,0,1);
    FM_E(*result,1,0) = FM_E(*m1,0,0)*FM_E(*m2,1,0) + FM_E(*m1,1,0)*FM_E(*m2,1,1);
    FM_E(*result,1,1) = FM_E(*m1,0,1)*FM_E(*m2,1,0) + FM_E(*m1,1,1)*FM_E(*m2,1,1);
}

void fm3_mm_multiply_m(FMatrix3 * m1, FMatrix3 * m2, FMatrix3 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0)*FM_E(*m2,0,0) + FM_E(*m1,1,0)*FM_E(*m2,0,1) + FM_E(*m1,2,0)*FM_E(*m2,0,2);
    FM_E(*result,1,0) = FM_E(*m1,0,0)*FM_E(*m2,1,0) + FM_E(*m1,1,0)*FM_E(*m2,1,1) + FM_E(*m1,2,0)*FM_E(*m2,1,2);
    FM_E(*result,2,0) = FM_E(*m1,0,0)*FM_E(*m2,2,0) + FM_E(*m1,1,0)*FM_E(*m2,2,1) + FM_E(*m1,2,0)*FM_E(*m2,2,2);

    FM_E(*result,0,1) = FM_E(*m1,0,1)*FM_E(*m2,0,0) + FM_E(*m1,1,1)*FM_E(*m2,0,1) + FM_E(*m1,2,1)*FM_E(*m2,0,2);
    FM_E(*result,1,1) = FM_E(*m1,0,1)*FM_E(*m2,1,0) + FM_E(*m1,1,1)*FM_E(*m2,1,1) + FM_E(*m1,2,1)*FM_E(*m2,1,2);
    FM_E(*result,2,1) = FM_E(*m1,0,1)*FM_E(*m2,2,0) + FM_E(*m1,1,1)*FM_E(*m2,2,1) + FM_E(*m1,2,1)*FM_E(*m2,2,2);

    FM_E(*result,0,2) = FM_E(*m1,0,2)*FM_E(*m2,0,0) + FM_E(*m1,1,2)*FM_E(*m2,0,1) + FM_E(*m1,2,2)*FM_E(*m2,0,2);
    FM_E(*result,1,2) = FM_E(*m1,0,2)*FM_E(*m2,1,0) + FM_E(*m1,1,2)*FM_E(*m2,1,1) + FM_E(*m1,2,2)*FM_E(*m2,1,2);
    FM_E(*result,2,2) = FM_E(*m1,0,2)*FM_E(*m2,2,0) + FM_E(*m1,1,2)*FM_E(*m2,2,1) + FM_E(*m1,2,2)*FM_E(*m2,2,2);
}

void fm4_mm_multiply_m(FMatrix4 * m1, FMatrix4 * m2, FMatrix4 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0)*FM_E(*m2,0,0) + FM_E(*m1,1,0)*FM_E(*m2,0,1) + FM_E(*m1,2,0)*FM_E(*m2,0,2) + FM_E(*m1,3,0)*FM_E(*m2,0,3);
    FM_E(*result,1,0) = FM_E(*m1,0,0)*FM_E(*m2,1,0) + FM_E(*m1,1,0)*FM_E(*m2,1,1) + FM_E(*m1,2,0)*FM_E(*m2,1,2) + FM_E(*m1,3,0)*FM_E(*m2,1,3);
    FM_E(*result,2,0) = FM_E(*m1,0,0)*FM_E(*m2,2,0) + FM_E(*m1,1,0)*FM_E(*m2,2,1) + FM_E(*m1,2,0)*FM_E(*m2,2,2) + FM_E(*m1,3,0)*FM_E(*m2,2,3);
    FM_E(*result,3,0) = FM_E(*m1,0,0)*FM_E(*m2,3,0) + FM_E(*m1,1,0)*FM_E(*m2,3,1) + FM_E(*m1,2,0)*FM_E(*m2,3,2) + FM_E(*m1,3,0)*FM_E(*m2,3,3);

    FM_E(*result,0,1) = FM_E(*m1,0,1)*FM_E(*m2,0,0) + FM_E(*m1,1,1)*FM_E(*m2,0,1) + FM_E(*m1,2,1)*FM_E(*m2,0,2) + FM_E(*m1,3,1)*FM_E(*m2,0,3);
    FM_E(*result,1,1) = FM_E(*m1,0,1)*FM_E(*m2,1,0) + FM_E(*m1,1,1)*FM_E(*m2,1,1) + FM_E(*m1,2,1)*FM_E(*m2,1,2) + FM_E(*m1,3,1)*FM_E(*m2,1,3);
    FM_E(*result,2,1) = FM_E(*m1,0,1)*FM_E(*m2,2,0) + FM_E(*m1,1,1)*FM_E(*m2,2,1) + FM_E(*m1,2,1)*FM_E(*m2,2,2) + FM_E(*m1,3,1)*FM_E(*m2,2,3);
    FM_E(*result,3,1) = FM_E(*m1,0,1)*FM_E(*m2,3,0) + FM_E(*m1,1,1)*FM_E(*m2,3,1) + FM_E(*m1,2,1)*FM_E(*m2,3,2) + FM_E(*m1,3,1)*FM_E(*m2,3,3);

    FM_E(*result,0,2) = FM_E(*m1,0,2)*FM_E(*m2,0,0) + FM_E(*m1,1,2)*FM_E(*m2,0,1) + FM_E(*m1,2,2)*FM_E(*m2,0,2) + FM_E(*m1,3,2)*FM_E(*m2,0,3);
    FM_E(*result,1,2) = FM_E(*m1,0,2)*FM_E(*m2,1,0) + FM_E(*m1,1,2)*FM_E(*m2,1,1) + FM_E(*m1,2,2)*FM_E(*m2,1,2) + FM_E(*m1,3,2)*FM_E(*m2,1,3);
    FM_E(*result,2,2) = FM_E(*m1,0,2)*FM_E(*m2,2,0) + FM_E(*m1,1,2)*FM_E(*m2,2,1) + FM_E(*m1,2,2)*FM_E(*m2,2,2) + FM_E(*m1,3,2)*FM_E(*m2,2,3);
    FM_E(*result,3,2) = FM_E(*m1,0,2)*FM_E(*m2,3,0) + FM_E(*m1,1,2)*FM_E(*m2,3,1) + FM_E(*m1,2,2)*FM_E(*m2,3,2) + FM_E(*m1,3,2)*FM_E(*m2,3,3);

    FM_E(*result,0,3) = FM_E(*m1,0,3)*FM_E(*m2,0,0) + FM_E(*m1,1,3)*FM_E(*m2,0,1) + FM_E(*m1,2,3)*FM_E(*m2,0,2) + FM_E(*m1,3,3)*FM_E(*m2,0,3);
    FM_E(*result,1,3) = FM_E(*m1,0,3)*FM_E(*m2,1,0) + FM_E(*m1,1,3)*FM_E(*m2,1,1) + FM_E(*m1,2,3)*FM_E(*m2,1,2) + FM_E(*m1,3,3)*FM_E(*m2,1,3);
    FM_E(*result,2,3) = FM_E(*m1,0,3)*FM_E(*m2,2,0) + FM_E(*m1,1,3)*FM_E(*m2,2,1) + FM_E(*m1,2,3)*FM_E(*m2,2,2) + FM_E(*m1,3,3)*FM_E(*m2,2,3);
    FM_E(*result,3,3) = FM_E(*m1,0,3)*FM_E(*m2,3,0) + FM_E(*m1,1,3)*FM_E(*m2,3,1) + FM_E(*m1,2,3)*FM_E(*m2,3,2) + FM_E(*m1,3,3)*FM_E(*m2,3,3);
}

void fm2_mm_add_m(FMatrix2 * m1, FMatrix2 * m2, FMatrix2 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) + FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) + FM_E(*m2,0,1);
    FM_E(*result,1,0) = FM_E(*m1,1,0) + FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) + FM_E(*m2,1,1);
}

void fm3_mm_add_m(FMatrix3 * m1, FMatrix3 * m2, FMatrix3 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) + FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) + FM_E(*m2,0,1);
    FM_E(*result,0,2) = FM_E(*m1,0,2) + FM_E(*m2,0,2);

    FM_E(*result,1,0) = FM_E(*m1,1,0) + FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) + FM_E(*m2,1,1);
    FM_E(*result,1,2) = FM_E(*m1,1,2) + FM_E(*m2,1,2);

    FM_E(*result,2,0) = FM_E(*m1,2,0) + FM_E(*m2,2,0);
    FM_E(*result,2,1) = FM_E(*m1,2,1) + FM_E(*m2,2,1);
    FM_E(*result,2,2) = FM_E(*m1,2,2) + FM_E(*m2,2,2);
}
void fm4_mm_add_m(FMatrix4 * m1, FMatrix4 * m2, FMatrix4 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) + FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) + FM_E(*m2,0,1);
    FM_E(*result,0,2) = FM_E(*m1,0,2) + FM_E(*m2,0,2);
    FM_E(*result,0,3) = FM_E(*m1,0,3) + FM_E(*m2,0,3);

    FM_E(*result,1,0) = FM_E(*m1,1,0) + FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) + FM_E(*m2,1,1);
    FM_E(*result,1,2) = FM_E(*m1,1,2) + FM_E(*m2,1,2);
    FM_E(*result,1,3) = FM_E(*m1,1,3) + FM_E(*m2,1,3);

    FM_E(*result,2,0) = FM_E(*m1,2,0) + FM_E(*m2,2,0);
    FM_E(*result,2,1) = FM_E(*m1,2,1) + FM_E(*m2,2,1);
    FM_E(*result,2,2) = FM_E(*m1,2,2) + FM_E(*m2,2,2);
    FM_E(*result,2,3) = FM_E(*m1,2,3) + FM_E(*m2,2,3);

    FM_E(*result,3,0) = FM_E(*m1,3,0) + FM_E(*m2,3,0);
    FM_E(*result,3,1) = FM_E(*m1,3,1) + FM_E(*m2,3,1);
    FM_E(*result,3,2) = FM_E(*m1,3,2) + FM_E(*m2,3,2);
    FM_E(*result,3,3) = FM_E(*m1,3,3) + FM_E(*m2,3,3);
}

void fm2_mm_subtract_m(FMatrix2 * m1, FMatrix2 * m2, FMatrix2 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) - FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) - FM_E(*m2,0,1);
    FM_E(*result,1,0) = FM_E(*m1,1,0) - FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) - FM_E(*m2,1,1);
}

void fm3_mm_subtract_m(FMatrix3 * m1, FMatrix3 * m2, FMatrix3 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) - FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) - FM_E(*m2,0,1);
    FM_E(*result,0,2) = FM_E(*m1,0,2) - FM_E(*m2,0,2);

    FM_E(*result,1,0) = FM_E(*m1,1,0) - FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) - FM_E(*m2,1,1);
    FM_E(*result,1,2) = FM_E(*m1,1,2) - FM_E(*m2,1,2);

    FM_E(*result,2,0) = FM_E(*m1,2,0) - FM_E(*m2,2,0);
    FM_E(*result,2,1) = FM_E(*m1,2,1) - FM_E(*m2,2,1);
    FM_E(*result,2,2) = FM_E(*m1,2,2) - FM_E(*m2,2,2);
}
void fm4_mm_subtract_m(FMatrix4 * m1, FMatrix4 * m2, FMatrix4 * result)
{
    FM_E(*result,0,0) = FM_E(*m1,0,0) - FM_E(*m2,0,0);
    FM_E(*result,0,1) = FM_E(*m1,0,1) - FM_E(*m2,0,1);
    FM_E(*result,0,2) = FM_E(*m1,0,2) - FM_E(*m2,0,2);
    FM_E(*result,0,3) = FM_E(*m1,0,3) - FM_E(*m2,0,3);

    FM_E(*result,1,0) = FM_E(*m1,1,0) - FM_E(*m2,1,0);
    FM_E(*result,1,1) = FM_E(*m1,1,1) - FM_E(*m2,1,1);
    FM_E(*result,1,2) = FM_E(*m1,1,2) - FM_E(*m2,1,2);
    FM_E(*result,1,3) = FM_E(*m1,1,3) - FM_E(*m2,1,3);

    FM_E(*result,2,0) = FM_E(*m1,2,0) - FM_E(*m2,2,0);
    FM_E(*result,2,1) = FM_E(*m1,2,1) - FM_E(*m2,2,1);
    FM_E(*result,2,2) = FM_E(*m1,2,2) - FM_E(*m2,2,2);
    FM_E(*result,2,3) = FM_E(*m1,2,3) - FM_E(*m2,2,3);

    FM_E(*result,3,0) = FM_E(*m1,3,0) - FM_E(*m2,3,0);
    FM_E(*result,3,1) = FM_E(*m1,3,1) - FM_E(*m2,3,1);
    FM_E(*result,3,2) = FM_E(*m1,3,2) - FM_E(*m2,3,2);
    FM_E(*result,3,3) = FM_E(*m1,3,3) - FM_E(*m2,3,3);
}
