#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <time.h>
#import "fftw3.h"

#define MATH_2_MUL_PI           6.28318530717958647692528676655900576839

static double G_zero(double sigma, int32_t n, double deltaQ)
{
    double result = 0.0;

    for (int32_t i = 0; i < n; i++)
    {
        double di = (double)i;
        double qn = di * deltaQ;
        double qnSquare = qn * qn;

        result += qnSquare * exp(-1.0 * sigma * qnSquare);        
    }

    return result;
}

static void G(int32_t P, double sigma, int32_t n, double deltaQ, double ** kernel)
{
    assert(kernel != NULL);

    const int32_t kernelSize = 2 * P + 1;
    const double gZero = G_zero(sigma, n, deltaQ);

    *kernel = malloc(sizeof(double) * kernelSize * kernelSize);

    for (int32_t k = -P; k < P + 1; k++)
    {
        for (int32_t l = -P; l < P + 1; l++)
        {
            const double dl = (double)l;
            const double dk = (double)k;
            const double r = sqrt(dk * dk + dl * dl);

            double element = 0.0;

            for (int32_t i = 0; i < n; i++)
            {
                double di = (double)i;
                double qn = di * deltaQ;
                double qnSquare = qn * qn;

                element += qnSquare * exp(-1.0 * sigma * qnSquare) * j0(r * qn);
            }

            const int32_t indexk = k + P;
            const int32_t indexl = l + P;
            const int32_t index = indexk * kernelSize + indexl;

            (*kernel)[index] = element / gZero;
        }
    }
}

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    double x = rand();
    double y = j0(x);

    double z = G_zero(1.0, 10000, 0.001);
    printf("%lf\n", z);

    double * result = NULL;
    G(6, 1.0, 10000, 0.001,&result);

    return 0;
}

