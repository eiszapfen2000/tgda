#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <string.h>
#import <time.h>
#import <Foundation/NSAutoreleasePool.h>
#import "Core/Timer/NPTimer.h"
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

    printf("\n");
}

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPTimer * timer = [[ NPTimer alloc ] init ];

    const int32_t resolution = 256;
    const int32_t lods = 16;

    fftwf_complex * dataSeparate    = fftwf_alloc_complex(resolution * resolution * lods);
    fftwf_complex * dataInterleaved = fftwf_alloc_complex(resolution * resolution * lods);

    fftwf_complex * targetSeparate      = fftwf_alloc_complex(resolution * resolution * lods);
    fftwf_complex * targetBatchSeparate = fftwf_alloc_complex(resolution * resolution * lods);
    fftwf_complex * targetInterleaved   = fftwf_alloc_complex(resolution * resolution * lods);

    const float rf = RAND_MAX;

    fftwf_plan planSeparate
        = fftwf_plan_dft_2d(resolution,
                            resolution,
                            dataSeparate,
                            targetSeparate,
                            FFTW_BACKWARD,
                            FFTW_ESTIMATE | FFTW_PRESERVE_INPUT);

    const int32_t rank = 2;
    const int32_t n[] = {resolution, resolution};
    const int32_t ni[] = {resolution * lods, resolution * lods};
    const int32_t iStride = 1;
    const int32_t oStride = 1;
    const int32_t iDist = resolution * resolution;
    const int32_t oDist = resolution * resolution;

    fftwf_plan planSeparateBatch
        = fftwf_plan_many_dft(
            rank, n, lods,
            dataSeparate, n, 1, iDist,
            targetBatchSeparate, n, 1, iDist,
            FFTW_BACKWARD, FFTW_ESTIMATE | FFTW_PRESERVE_INPUT
            );

    fftwf_plan planInterleavedBatch
        = fftwf_plan_many_dft(
            rank, n, lods,
            dataInterleaved, n, lods, 1,
            targetInterleaved, n, lods, 1,
            FFTW_BACKWARD, FFTW_ESTIMATE | FFTW_PRESERVE_INPUT
            );

    memset(dataSeparate,        0, resolution * resolution * lods * sizeof(fftwf_complex));
    memset(dataInterleaved,     0, resolution * resolution * lods * sizeof(fftwf_complex));
    memset(targetSeparate,      0, resolution * resolution * lods * sizeof(fftwf_complex));
    memset(targetInterleaved,   0, resolution * resolution * lods * sizeof(fftwf_complex));
    memset(targetBatchSeparate, 0, resolution * resolution * lods * sizeof(fftwf_complex));

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

    //print_separate_spectrum(lods, resolution, dataSeparate);

    [ timer update ];
    for ( int32_t l = 0; l < lods; l++ )
    {
        int32_t separateOffset = l * resolution * resolution;

        fftwf_execute_dft(planSeparate, &dataSeparate[separateOffset], &targetSeparate[separateOffset]);
    }
    [ timer update ];

    const double separate = [ timer frameTime ];

    //print_separate_spectrum(lods, resolution, targetSeparate);

    [ timer update ];
    fftwf_execute_dft(planSeparateBatch, dataSeparate, targetBatchSeparate);
    [ timer update ];

    const double batch = [ timer frameTime ];

    //print_separate_spectrum(lods, resolution, targetBatchSeparate);

    [ timer update ];
    fftwf_execute_dft(planInterleavedBatch, dataInterleaved, targetInterleaved);
    [ timer update ];

    const double interleaved = [ timer frameTime ];

    //print_interleaved_spectrum(lods, resolution, dataInterleaved);
    //print_interleaved_spectrum(lods, resolution, targetInterleaved);


    NSLog(@"S:%lf B:%lf I:%lf", separate, batch, interleaved);

    fftwf_destroy_plan(planSeparate);
    fftwf_destroy_plan(planSeparateBatch);
    fftwf_destroy_plan(planInterleavedBatch);

    fftwf_free(dataSeparate);
    fftwf_free(dataInterleaved);
    fftwf_free(targetSeparate);
    fftwf_free(targetInterleaved);
    fftwf_free(targetBatchSeparate);

    fftwf_cleanup();

    DESTROY(timer);
    DESTROY(pool);

    return 0;
}

