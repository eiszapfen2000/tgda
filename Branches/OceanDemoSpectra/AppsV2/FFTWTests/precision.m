#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <time.h>
#import "fftw3.h"

#define MATH_2_MUL_PI           6.28318530717958647692528676655900576839

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    /*
        complexPlans[i]
            = fftwf_plan_dft_2d(resolutions[i],
                                resolutions[i],
                                source,
                                complexTarget,
                                FFTW_BACKWARD,
                                FFTW_MEASURE);
    */

    fftw_complex * test           = fftw_alloc_complex(5);
    fftw_complex * forwardResult  = fftw_alloc_complex(5);
    fftw_complex * backwardResult = fftw_alloc_complex(5);


    fftw_plan forwardPlan  = fftw_plan_dft_1d(5, test, forwardResult, FFTW_FORWARD, FFTW_MEASURE);
    fftw_plan backwardPlan = fftw_plan_dft_1d(5, forwardResult, backwardResult, FFTW_BACKWARD, FFTW_MEASURE);

    for (int i = 0; i < 5; i++)
    {
        test[i][0] = (double)(i + 1);
        test[i][1] = (double)(-i);
        //test[i][0] = (float)rand();
        //test[i][1] = (float)rand();

        printf("%f + i%f\n", test[i][0], test[i][1]);
    }

    fftw_execute(forwardPlan);
    fftw_execute(backwardPlan);

    printf("FFTW Forward result\n");
    for (int i = 0; i < 5; i++)
    {
        printf("%f + i%f\n", forwardResult[i][0], forwardResult[i][1]);
    }
    printf("FFTW Backward result\n");
    for (int i = 0; i < 5; i++)
    {
        printf("%f + i%f\n", backwardResult[i][0], backwardResult[i][1]);
    }
    printf("FFTW Backward normalised result\n");
    for (int i = 0; i < 5; i++)
    {
        printf("%f + i%f\n", backwardResult[i][0] / 5.0, backwardResult[i][1] / 5.0);
    }
    printf("\n");

    /* complex multiplication
       x = a + i*b
       y = c + i*d
       xy = (ac-bd) + i(ad+bc)
    */

    /*
        exp(ix) = cos(x) + i*sin(x)
    */


    for (int k = 0; k < 5; k++)
    {
        fftw_complex sum;
        sum[0] = sum[1] = 0.0;

        for (int j = 0; j < 5; j++)
        {
            double exponent = -MATH_2_MUL_PI * j * k;
            exponent = exponent / 5.0;

            fftw_complex expTerm;
            expTerm[0] = cos(exponent);
            expTerm[1] = sin(exponent);

            fftw_complex completeTerm;
            completeTerm[0] = test[j][0] * expTerm[0] - test[j][1] * expTerm[1];
            completeTerm[1] = test[j][0] * expTerm[1] + test[j][1] * expTerm[0];

            sum[0] += completeTerm[0];
            sum[1] += completeTerm[1];
        }

        forwardResult[k][0] = sum[0];
        forwardResult[k][1] = sum[1];
    }

    for (int i = 0; i < 5; i++)
    {
        printf("%f + i%f\n", forwardResult[i][0], forwardResult[i][1]);
    }

    for (int k = 0; k < 5; k++)
    {
        fftw_complex sum;
        sum[0] = sum[1] = 0.0;

        for (int j = 0; j < 5; j++)
        {
            double exponent = MATH_2_MUL_PI * j * k;
            exponent = exponent / 5.0;

            fftw_complex expTerm;
            expTerm[0] = cos(exponent);
            expTerm[1] = sin(exponent);

            fftw_complex completeTerm;
            completeTerm[0] = forwardResult[j][0] * expTerm[0] - forwardResult[j][1] * expTerm[1];
            completeTerm[1] = forwardResult[j][0] * expTerm[1] + forwardResult[j][1] * expTerm[0];

            sum[0] += completeTerm[0];
            sum[1] += completeTerm[1];
        }

        backwardResult[k][0] = sum[0];
        backwardResult[k][1] = sum[1];
    }

    for (int i = 0; i < 5; i++)
    {
        printf("%f + i%f\n", backwardResult[i][0] / 5.0, backwardResult[i][1] / 5.0);
    }

    fftw_destroy_plan(forwardPlan);
    fftw_destroy_plan(backwardPlan);
    fftw_free(test);
    fftw_free(forwardResult);
    fftw_free(backwardResult);


    return 0;
}

