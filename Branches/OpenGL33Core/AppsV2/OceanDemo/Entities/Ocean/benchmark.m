#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <stdio.h>
#import <time.h>
#import <Foundation/NSString.h>
#import "fftw3.h"
#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "ODConstants.h"
#import "ODGaussianRNG.h"

/*
- (void) generatePMSpectrum
{
    const OdPiersonMoskowitzGeneratorSettings settings
        = currentGeneratorSettings.piersonmoskowitz;

    const IVector2 resolution  = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const float U10   = settings.U10;

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    const float omega_p = peak_energy_wave_frequency_pm(U10);

    float mssX  = 0.0;
    float mssY  = 0.0;
    float mssXY = 0.0;

    for ( int32_t l = 0; l < numberOfLods; l++ )
    {
        const FVector2 lastSize
            = ( l == 0 ) ? fv2_zero() : fv2_v_from_v2(&currentGeometry.sizes[l - 1]);

        const FVector2 currentSize = fv2_v_from_v2(&currentGeometry.sizes[l]);

        const float dkx = MATH_2_MUL_PIf / currentSize.x;
        const float dky = MATH_2_MUL_PIf / currentSize.y;

        const float kMinX = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution.x ) / lastSize.x );
        const float kMinY = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution.y ) / lastSize.y );
        const float kMin = sqrtf(kMinX*kMinX + kMinY*kMinY);

        const int32_t offset = l * numberOfLodElements;

        for ( int32_t i = 0; i < resolution.y; i++ )
        {
            for ( int32_t j = 0; j < resolution.x; j++ )
            {
                const int32_t index = offset + j + resolution.x * i;

                const float xi_r = (float)randomNumbers[2 * index    ];
                const float xi_i = (float)randomNumbers[2 * index + 1];

                const float di = i;
                const float dj = j;

                // wave vector
                const float kx = (n + dj) * dkx;
                const float ky = (m - di) * dky;

                // wave number
                const float k = sqrtf(kx*kx + ky*ky);

                // deep water dispersion relation
                const float omega = sqrtf(k * EARTH_ACCELERATIONf);

                // Theta in wave vector domain
                float Theta_complete = 0.0f;

                if (k > kMin)
                {
                    // Theta in wave frequency domain
                    const float Theta = energy_pm_wave_frequency(omega, U10);
                    // convert Theta to wave number domain
                    const float Theta_wavenumber = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);
                    // convert Theta to wave vector domain
                    const float Theta_wavevector = Theta_wavenumber / k;

                    const float directionalSpread
                        = directional_spreading_mitsuyasu_hasselmann(omega_p, omega, 0.0f, atan2f(ky, kx));

                    Theta_complete = Theta_wavevector * directionalSpread;

                    mssX  += (kx * kx) * (dkx * dky) * Theta_complete;
                    mssY  += (ky * ky) * (dkx * dky) * Theta_complete;
                    mssXY += (kx * kx + ky * ky) * (dkx * dky) * Theta_complete;
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);

                baseSpectrum[index] = Theta_complete;
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;

                //printf("%+f %+fi ", H0[index][0], H0[index][1]);
            }

            //printf("\n");
        }
    }
}
*/

typedef struct SpectrumGeometry
{
    int geometryResolution;
    int gradientResolution;
    int numberOfLods;
    double * sizes;
}
SpectrumGeometry;

typedef enum SpectrumGenerator
{
    Unknown  = -1,
    PiersonMoskowitz = 0,
    JONSWAP = 1,
    Donelan = 2,
    Unified  = 3
}
SpectrumGenerator;

enum
{
    GeneratorOptionsHeights      = (1 << 0),
    GeneratorOptionsDisplacement = (1 << 1),
    GeneratorOptionsGradient     = (1 << 2),
    GeneratorOptionsDisplacementDerivatives = (1 << 3)
};

typedef NSUInteger GeneratorOptions;

typedef struct PiersonMoskowitzGeneratorSettings
{
    double U10;
}
PiersonMoskowitzGeneratorSettings;

typedef struct JONSWAPGeneratorSettings
{
    double U10;
    double fetch;
}
JONSWAPGeneratorSettings;

typedef struct DonelanGeneratorSettings
{
    double U10;
    double fetch;
}
DonelanGeneratorSettings;

typedef struct UnifiedGeneratorSettings
{
    double U10;
    double fetch;
}
UnifiedGeneratorSettings;


typedef struct GeneratorSettings
{
    SpectrumGenerator generatorType;
    GeneratorOptions  options;
    union
    {
        PiersonMoskowitzGeneratorSettings piersonmoskowitz;
        JONSWAPGeneratorSettings jonswap;
        DonelanGeneratorSettings donelan;
        UnifiedGeneratorSettings unified;
    };
}
GeneratorSettings;

static void generatePM(
	const SpectrumGeometry * const geometry,
	const GeneratorSettings * const settings,
	const double * const randomNumbers,
	fftwf_complex * const H0
	)
{
	
}

int main (int argc, char **argv)
{
	double maxSize = 100; // metre

	SpectrumGeometry geometry;
	geometry.numberOfLods = 4;
	geometry.geometryResolution = 64;
	geometry.gradientResolution = 64;
	geometry.sizes = malloc(sizeof(double)*geometry.numberOfLods);
	geometry.sizes[0] = maxSize;

	const double goldenRatio = (1.0 + sqrt(5.0)) / 2.0;
	const double goldenRatioLong = 1.0 / goldenRatio;
	const double goldenRatioShort = 1.0 - (1.0 / goldenRatio);

	for ( int i = 1; i < geometry.numberOfLods; i++ )
	{
		const float s = geometry.sizes[i-1];
		geometry.sizes[i] = s * goldenRatioShort;
	}

    int necessaryResolution = MAX(geometry.geometryResolution, geometry.gradientResolution);
    const size_t n
        = necessaryResolution * necessaryResolution * geometry.numberOfLods;

	OdGaussianRng * gaussianRNG = odgaussianrng_alloc_init();
    double * randomNumbers = malloc(sizeof(double) * 2 * n);
    odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * geometry.numberOfLods * necessaryResolution * necessaryResolution);
    odgaussianrng_free(gaussianRNG);

    GeneratorSettings settings;
    settings.generatorType = PiersonMoskowitz;
    settings.piersonmoskowitz.U10 = 10.0;

    fftwf_complex * H0 = fftwf_alloc_complex(n);
    fftwf_free(H0);

}