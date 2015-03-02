#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdio.h>
#import <stdlib.h>
#import <time.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/NSThread.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSData+NPEngine.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "ODFrequencySpectrumFloat.h"

#define MATH_g 9.81

static void print_complex_spectrum(int32_t resolution, fftwf_complex * spectrum)
{
    printf("Complex spectrum\n");
    for ( int32_t j = 0; j < resolution; j++ )
    {
        for ( int32_t k = 0; k < resolution; k++ )
        {
            printf("%+f %+fi ", spectrum[j * resolution + k][0], spectrum[j * resolution + k][1]);
        }

        printf("\n");
    }

    printf("\n");
}

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    float a = 3.7 * powf(10.0f, -5.0f);
    float b = 3.7e-5;

    const float c = 2.2f * powf(10.0f, 4.0f);
    const float d = 2.2e4f;

    printf("%f %f\n", c, d);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    ODFrequencySpectrumFloat * s = [[ ODFrequencySpectrumFloat alloc ] init ];

    OdGeneratorSettings generatorSettings;

    generatorSettings.options = OdGeneratorOptionsHeights;
    generatorSettings.generatorType = PiersonMoskowitz;
    generatorSettings.piersonmoskowitz.U10 = 10.0;
    generatorSettings.spectrumScale = 1.0;

    OdSpectrumGeometry geometry = geometry_zero();
    geometry_init_with_resolutions_and_lods(&geometry, 4, 4, 2);
    // first LOD is the largest one, set it to our desired size
    geometry_set_size(&geometry, 0, 83.0);
    geometry_set_size(&geometry, 1, 7.0);

    OdFrequencySpectrumFloat complexSpectrumPM;
    OdFrequencySpectrumFloat complexSpectrumJONSWAP;
    OdFrequencySpectrumFloat complexSpectrumDonelan;
    OdFrequencySpectrumFloat complexSpectrumUnified;

    complexSpectrumPM
        = [ s generateFloatSpectrumWithGeometry:geometry
                                      generator:generatorSettings
                                         atTime:1.0
                           generateBaseGeometry:YES ];

    generatorSettings.generatorType = JONSWAP;
    generatorSettings.jonswap.U10 = 10.0;
    generatorSettings.jonswap.fetch = 100000.0;

    complexSpectrumJONSWAP
        = [ s generateFloatSpectrumWithGeometry:geometry
                                      generator:generatorSettings
                                         atTime:1.0
                           generateBaseGeometry:YES ];

    generatorSettings.generatorType = Donelan;
    generatorSettings.donelan.U10 = 10.0;
    generatorSettings.donelan.fetch = 100000.0;

    complexSpectrumDonelan
        = [ s generateFloatSpectrumWithGeometry:geometry
                                      generator:generatorSettings
                                         atTime:1.0
                           generateBaseGeometry:YES ];

    generatorSettings.generatorType = Unified;
    generatorSettings.unified.U10 = 10.0;
    generatorSettings.unified.fetch = 100000.0;

    complexSpectrumUnified
        = [ s generateFloatSpectrumWithGeometry:geometry
                                      generator:generatorSettings
                                         atTime:1.0
                           generateBaseGeometry:YES ];

    print_complex_spectrum(4, complexSpectrumPM.height);
    print_complex_spectrum(4, complexSpectrumJONSWAP.height);
    print_complex_spectrum(4, complexSpectrumDonelan.height);
    print_complex_spectrum(4, complexSpectrumPM.height);

    DESTROY(s);
    DESTROY(pool);

    /*
    for (double o = 0.0; o <= 2.0 * M_PI; o += 0.5)
    {
        printf("%f %f\n", o, energy_pm_wave_frequency(o, 10.0));
    }
    */

    /*
    for (double o = 0.0; o <= 2.0 * M_PI; o += 0.5)
    {
        double k = (o * o) / 9.81;
        printf("%f %f\n", o, energy_pm_wave_number(k, 10.0));
    }
    */

    /*
    const int32_t resolution = 4;
    const double area = 10.0;
    const double U10 = 10.0;
    const double omega_p = energy_pm_omega_p(U10);

    const double deltakx = 2.0 * M_PI / area;
    const double deltaky = 2.0 * M_PI / area;

    double mss_x = 0.0;
    double mss_z = 0.0;
    double mss = 0.0;

    for (int32_t alpha = -resolution/2; alpha < resolution/2; alpha++)
    {
        for (int32_t beta = resolution/2; beta > -resolution/2; beta--)
        {
            double kx = alpha * deltakx;
            double ky = beta  * deltaky;
            double k  = sqrtf(kx*kx + ky*ky);

            //printf("%d %d %f %f %f\n", alpha, beta, kx , ky, k);

            double omega = sqrtf(k * MATH_g);
            double Theta = energy_pm_wave_frequency(omega, U10);

            Vector2 k_wv = {.x = kx, .y = ky};
            double Theta_k_wv = energy_pm_wave_vector(k_wv, U10);

            //printf("%f %f\n", omega, Theta_k_wv);

            double theta = atan2(ky, kx);

            double dir = directional_mitsuyasu(omega_p, omega, 0.0, theta);
            double amplitude = sqrt(2.0 * Theta_k_wv * dir * deltakx * deltaky);

            mss_x += kx*kx*Theta_k_wv*dir*deltakx*deltakx;
            mss_z += ky*ky*Theta_k_wv*dir*deltaky*deltaky;
            mss += (kx*kx+ky*ky)*Theta_k_wv*dir*deltakx*deltaky;

            printf("%f\n", amplitude);
        }
    }

    printf("%f %f %f\n", mss_x, mss_z, mss);
    */

    return EXIT_SUCCESS;
}

