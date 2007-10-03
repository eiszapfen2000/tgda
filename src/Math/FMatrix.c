#include "FMatrix.h"

void fm2_mm_multiply_m(FMatrix2 * m1, FMatrix2 * m2, FMatrix2 * result)
{
    FM_ELEMENT(*result,0,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,0,1);
    FM_ELEMENT(*result,0,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,0,1);
    FM_ELEMENT(*result,1,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,1,1);
    FM_ELEMENT(*result,1,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,1,1);
}

void fm3_mm_multiply_m(FMatrix3 * m1, FMatrix3 * m2, FMatrix3 * result)
{
    FM_ELEMENT(*result,0,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,0,1)
                              + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,0,2);
    FM_ELEMENT(*result,1,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,1,1)
                              + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,1,2);
    FM_ELEMENT(*result,2,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,2,1)
                              + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,2,2);

    FM_ELEMENT(*result,0,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,0,1)
                              + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,0,2);
    FM_ELEMENT(*result,1,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,1,1)
                              + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,1,2);
    FM_ELEMENT(*result,2,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,2,1)
                              + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,2,2);

    FM_ELEMENT(*result,0,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,0,1)
                              + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,0,2);
    FM_ELEMENT(*result,1,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,1,1)
                              + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,1,2);
    FM_ELEMENT(*result,2,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,2,1)
                              + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,2,2);
}

void fm4_mm_multiply_m(FMatrix4 * m1, FMatrix4 * m2, FMatrix4 * result)
{
    FM_ELEMENT(*result,0,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,0,1) + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,0,2)
                            + FM_ELEMENT(*m1,3,0)*FM_ELEMENT(*m2,0,3);

    FM_ELEMENT(*result,1,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,1,1) + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,1,2)
                            + FM_ELEMENT(*m1,3,0)*FM_ELEMENT(*m2,1,3);

    FM_ELEMENT(*result,2,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,2,1) + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,2,2)
                            + FM_ELEMENT(*m1,3,0)*FM_ELEMENT(*m2,2,3);

    FM_ELEMENT(*result,3,0) = FM_ELEMENT(*m1,0,0)*FM_ELEMENT(*m2,3,0) + FM_ELEMENT(*m1,1,0)*FM_ELEMENT(*m2,3,1) + FM_ELEMENT(*m1,2,0)*FM_ELEMENT(*m2,3,2)
                            + FM_ELEMENT(*m1,3,0)*FM_ELEMENT(*m2,3,3);

    FM_ELEMENT(*result,0,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,0,1) + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,0,2)
                            + FM_ELEMENT(*m1,3,1)*FM_ELEMENT(*m2,0,3);

    FM_ELEMENT(*result,1,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,1,1) + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,1,2)
                            + FM_ELEMENT(*m1,3,1)*FM_ELEMENT(*m2,1,3);

    FM_ELEMENT(*result,2,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,2,1) + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,2,2)
                            + FM_ELEMENT(*m1,3,1)*FM_ELEMENT(*m2,2,3);

    FM_ELEMENT(*result,3,1) = FM_ELEMENT(*m1,0,1)*FM_ELEMENT(*m2,3,0) + FM_ELEMENT(*m1,1,1)*FM_ELEMENT(*m2,3,1) + FM_ELEMENT(*m1,2,1)*FM_ELEMENT(*m2,3,2)
                            + FM_ELEMENT(*m1,3,1)*FM_ELEMENT(*m2,3,3);

    FM_ELEMENT(*result,0,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,0,1) + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,0,2)
                            + FM_ELEMENT(*m1,3,2)*FM_ELEMENT(*m2,0,3);

    FM_ELEMENT(*result,1,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,1,1) + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,1,2)
                            + FM_ELEMENT(*m1,3,2)*FM_ELEMENT(*m2,1,3);

    FM_ELEMENT(*result,2,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,2,1) + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,2,2)
                            + FM_ELEMENT(*m1,3,2)*FM_ELEMENT(*m2,2,3);

    FM_ELEMENT(*result,3,2) = FM_ELEMENT(*m1,0,2)*FM_ELEMENT(*m2,3,0) + FM_ELEMENT(*m1,1,2)*FM_ELEMENT(*m2,3,1) + FM_ELEMENT(*m1,2,2)*FM_ELEMENT(*m2,3,2)
                            + FM_ELEMENT(*m1,3,2)*FM_ELEMENT(*m2,3,3);

    FM_ELEMENT(*result,0,3) = FM_ELEMENT(*m1,0,3)*FM_ELEMENT(*m2,0,0) + FM_ELEMENT(*m1,1,3)*FM_ELEMENT(*m2,0,1) + FM_ELEMENT(*m1,2,3)*FM_ELEMENT(*m2,0,2)
                            + FM_ELEMENT(*m1,3,3)*FM_ELEMENT(*m2,0,3);

    FM_ELEMENT(*result,1,3) = FM_ELEMENT(*m1,0,3)*FM_ELEMENT(*m2,1,0) + FM_ELEMENT(*m1,1,3)*FM_ELEMENT(*m2,1,1) + FM_ELEMENT(*m1,2,3)*FM_ELEMENT(*m2,1,2)
                            + FM_ELEMENT(*m1,3,3)*FM_ELEMENT(*m2,1,3);

    FM_ELEMENT(*result,2,3) = FM_ELEMENT(*m1,0,3)*FM_ELEMENT(*m2,2,0) + FM_ELEMENT(*m1,1,3)*FM_ELEMENT(*m2,2,1) + FM_ELEMENT(*m1,2,3)*FM_ELEMENT(*m2,2,2)
                            + FM_ELEMENT(*m1,3,3)*FM_ELEMENT(*m2,2,3);

    FM_ELEMENT(*result,3,3) = FM_ELEMENT(*m1,0,3)*FM_ELEMENT(*m2,3,0) + FM_ELEMENT(*m1,1,3)*FM_ELEMENT(*m2,3,1) + FM_ELEMENT(*m1,2,3)*FM_ELEMENT(*m2,3,2)
                            + FM_ELEMENT(*m1,3,3)*FM_ELEMENT(*m2,3,3);
}
