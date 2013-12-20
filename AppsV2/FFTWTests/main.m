#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <time.h>
#import "fftw3.h"

#define MATH_2_MUL_PI           6.28318530717958647692528676655900576839

static void print_separate_spectrum(int32_t lods, int32_t resolution, fftwf_complex * spectrum)
{
    for ( int32_t l = 0; l < lods; l++ )
    {
        printf("Lod %d\n", l);

        for ( int32_t j = 0; j < resolution; j++ )
        {
            for ( int32_t k = 0; k < resolution; k++ )
            {
                int32_t offset = l * resolution * resolution;
                int32_t lindex = j * resolution + k;
                int32_t index  = offset + lindex;

                printf("%+f %+fi ", spectrum[index][0], spectrum[index][1]);
            }

            printf("\n");
        }

        printf("\n");
    }
}

static void print_interleaved_spectrum(int32_t lods, int32_t resolution, fftwf_complex * spectrum)
{
    for ( int32_t j = 0; j < resolution; j++ )
    {
        for ( int32_t k = 0; k < resolution; k++ )
        {
            for ( int32_t l = 0; l < lods; l++ )
            {
                int32_t interleaved = lods * resolution * j + k * lods + l;
                printf("%+f %+fi ", spectrum[interleaved][0], spectrum[interleaved][1]);
            }
        }

        printf("\n");
    }
}

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    const int32_t resolution = 4;
    const int32_t lods = 2;

    fftwf_complex * dataSeparate    = fftwf_alloc_complex(resolution * resolution * lods);
    fftwf_complex * dataInterleaved = fftwf_alloc_complex(resolution * resolution * lods);

    fftwf_complex * targetSeparate    = fftwf_alloc_complex(resolution * resolution * lods);
    fftwf_complex * targetInterleaved = fftwf_alloc_complex(resolution * resolution * lods);

    const float rf = RAND_MAX;

    fftwf_plan planSeparate
        = fftwf_plan_dft_2d(resolution,
                            resolution,
                            dataSeparate,
                            targetSeparate,
                            FFTW_BACKWARD,
                            FFTW_ESTIMATE);

    for ( int32_t l = 0; l < lods; l++ )
    {
        for ( int32_t j = 0; j < resolution; j++ )
        {
            for ( int32_t i = 0; i < resolution; i++ )
            {
                int32_t a = rand();
                int32_t b = rand();

                float fa = a;
                float fb = b;

                float r = fa / rf;
                float c = fb / rf;

                int32_t separateOffset = l * resolution * resolution;
                int32_t separatelIndex = j * resolution + i;

                dataSeparate[separateOffset + separatelIndex][0] = r;
                dataSeparate[separateOffset + separatelIndex][1] = c;

                int32_t interleaved = lods * resolution * j + i * lods + l;

                dataInterleaved[interleaved][0] = r;
                dataInterleaved[interleaved][1] = c;
            }
        }
    }

    print_separate_spectrum(lods, resolution, dataSeparate);
    print_interleaved_spectrum(lods, resolution, dataInterleaved);

    fftwf_destroy_plan(planSeparate);

    fftwf_free(dataSeparate);
    fftwf_free(dataInterleaved);
    fftwf_free(targetSeparate);
    fftwf_free(targetInterleaved);

    return 0;
}

