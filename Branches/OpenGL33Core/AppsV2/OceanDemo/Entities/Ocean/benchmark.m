#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <stdio.h>
#import <time.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSString.h>
#import "fftw3.h"
#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/Timer/NPTimer.h"
#import "ODConstants.h"
#import "ODEnergy.h"
#import "ODGaussianRNG.h"

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

typedef struct SpectrumParameters
{
    double U10;
    double fetch;
}
SpectrumParameters;

typedef struct GeneratorSettings
{
    SpectrumGenerator  generatorType;
    SpectrumParameters parameters;
    GeneratorOptions   options;
}
GeneratorSettings;

typedef struct FrequencySpectrum
{
    float timestamp;
    fftwf_complex * height;
    fftwf_complex * gradient;
    fftwf_complex * displacement;
    fftwf_complex * displacementXdXdZ;
    fftwf_complex * displacementZdXdZ;
}
FrequencySpectrum;

typedef enum Quadrants
{
    Quadrant_1_3 =  1,
    Quadrant_2_4 = -1
}
Quadrants;

/*===============================================================================================*/

static void print_complex_spectrum(int resolution, fftwf_complex * spectrum)
{
    printf("Complex spectrum\n");
    for ( int j = 0; j < resolution; j++ )
    {
        for ( int k = 0; k < resolution; k++ )
        {
            //printf("%+f %+fi ", crealf(spectrum[j * resolution + k]), cimagf(spectrum[j * resolution + k]));
            printf("%+f %+fi ", spectrum[j * resolution + k][0], spectrum[j * resolution + k][1]);
        }

        printf("\n");
    }

    printf("\n");
}

/*===============================================================================================*/

static void generatePM(
    const SpectrumGeometry * const geometry,
    const SpectrumParameters * const settings,
    const double * const randomNumbers,
    fftwf_complex * const H0
    )
{
    const int resolution  = MAX(geometry->geometryResolution, geometry->gradientResolution);
    const float fresolution = (float)resolution;

    const int numberOfLods = geometry->numberOfLods;
    const int numberOfLodElements = resolution * resolution;

    const float U10   = settings->U10;

    const float n = -(fresolution / 2.0f);
    const float m =  (fresolution / 2.0f);

    const float omega_p = peak_energy_wave_frequency_pm(U10);

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const float lastSize = ( l == 0 ) ? 0.0f : geometry->sizes[l - 1];
        const float currentSize = geometry->sizes[l];

        const float dkx = MATH_2_MUL_PIf / currentSize;
        const float dky = MATH_2_MUL_PIf / currentSize;

        const float kMinX = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMinY = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMin = sqrtf(kMinX*kMinX + kMinY*kMinY);

        const int offset = l * numberOfLodElements;

        for ( int i = 0; i < resolution; i++ )
        {
            for ( int j = 0; j < resolution; j++ )
            {
                const int index = offset + j + resolution * i;

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
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;
            }
        }
    }
}

static void generateJONSWAP(
    const SpectrumGeometry * const geometry,
    const SpectrumParameters * const settings,
    const double * const randomNumbers,
    fftwf_complex * const H0
    )
{
    const int resolution  = MAX(geometry->geometryResolution, geometry->gradientResolution);
    const float fresolution = (float)resolution;

    const int numberOfLods = geometry->numberOfLods;
    const int numberOfLodElements = resolution * resolution;

    const float U10   = settings->U10;
    const float fetch = settings->fetch;

    const float n = -(fresolution / 2.0f);
    const float m =  (fresolution / 2.0f);

    const float omega_p = peak_energy_wave_frequency_jonswap(U10, fetch);

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const float lastSize = ( l == 0 ) ? 0.0f : geometry->sizes[l - 1];
        const float currentSize = geometry->sizes[l];

        const float dkx = MATH_2_MUL_PIf / currentSize;
        const float dky = MATH_2_MUL_PIf / currentSize;

        const float kMinX = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMinY = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMin = sqrtf(kMinX*kMinX + kMinY*kMinY);

        const int offset = l * numberOfLodElements;

        for ( int i = 0; i < resolution; i++ )
        {
            for ( int j = 0; j < resolution; j++ )
            {
                const int index = offset + j + resolution * i;

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
                    const float Theta = energy_jonswap_wave_frequency(omega, U10, fetch);
                    // convert Theta to wave number domain
                    const float Theta_wavenumber = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);
                    // convert Theta to wave vector domain
                    const float Theta_wavevector = Theta_wavenumber / k;

                    const float directionalSpread
                        = directional_spreading_mitsuyasu_hasselmann(omega_p, omega, 0.0f, atan2f(ky, kx));

                    Theta_complete = Theta_wavevector * directionalSpread;
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;
            }
        }
    }   
}

static void generateDonelan(
    const SpectrumGeometry * const geometry,
    const SpectrumParameters * const settings,
    const double * const randomNumbers,
    fftwf_complex * const H0
    )
{
    const int resolution  = MAX(geometry->geometryResolution, geometry->gradientResolution);
    const float fresolution = (float)resolution;

    const int numberOfLods = geometry->numberOfLods;
    const int numberOfLodElements = resolution * resolution;

    const float U10   = settings->U10;
    const float fetch = settings->fetch;

    const float n = -(fresolution / 2.0f);
    const float m =  (fresolution / 2.0f);

    const float omega_p = peak_energy_wave_frequency_donelan(U10, fetch);

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const float lastSize = ( l == 0 ) ? 0.0f : geometry->sizes[l - 1];
        const float currentSize = geometry->sizes[l];

        const float dkx = MATH_2_MUL_PIf / currentSize;
        const float dky = MATH_2_MUL_PIf / currentSize;

        const float kMinX = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMinY = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMin = sqrtf(kMinX*kMinX + kMinY*kMinY);

        const int offset = l * numberOfLodElements;

        for ( int i = 0; i < resolution; i++ )
        {
            for ( int j = 0; j < resolution; j++ )
            {
                const int index = offset + j + resolution * i;

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
                    const float Theta = energy_donelan_wave_frequency(omega, U10, fetch);
                    // convert Theta from wave frequency domain to wave number domain
                    const float Theta_wavenumber = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);
                    // convert Theta from wave number domain to wave vector domain
                    const float Theta_wavevector = Theta_wavenumber / k;

                    const float directionalSpread
                        = directional_spreading_mitsuyasu_hasselmann(omega_p, omega, 0.0f, atan2f(ky, kx));

                    Theta_complete = Theta_wavevector * directionalSpread;
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;
            }
        }
    }   
}

static void generateUnified(
    const SpectrumGeometry * const geometry,
    const SpectrumParameters * const settings,
    const double * const randomNumbers,
    fftwf_complex * const H0
    )
{
    const int resolution  = MAX(geometry->geometryResolution, geometry->gradientResolution);
    const float fresolution = (float)resolution;

    const int numberOfLods = geometry->numberOfLods;
    const int numberOfLodElements = resolution * resolution;

    const float U10   = settings->U10;
    const float fetch = settings->fetch;

    const float n = -(fresolution / 2.0f);
    const float m =  (fresolution / 2.0f);

    const float k_p = peak_energy_wave_number_unified(U10, fetch);

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const float lastSize = ( l == 0 ) ? 0.0f : geometry->sizes[l - 1];
        const float currentSize = geometry->sizes[l];

        const float dkx = MATH_2_MUL_PIf / currentSize;
        const float dky = MATH_2_MUL_PIf / currentSize;

        const float kMinX = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMinY = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution ) / lastSize );
        const float kMin = sqrtf(kMinX*kMinX + kMinY*kMinY);

        const int offset = l * numberOfLodElements;

        for ( int i = 0; i < resolution; i++ )
        {
            for ( int j = 0; j < resolution; j++ )
            {
                const int index = offset + j + resolution * i;

                const float xi_r = (float)randomNumbers[2 * index    ];
                const float xi_i = (float)randomNumbers[2 * index + 1];

                const float di = i;
                const float dj = j;

                // wave vector
                const float kx = (n + dj) * dkx;
                const float ky = (m - di) * dky;

                // wave number
                const float k = sqrtf(kx*kx + ky*ky);

                // Theta in wave vector domain
                float Theta_complete = 0.0f;

                if (k > kMin)
                {
                    const float Theta_wavenumber = energy_unified_wave_number(k, U10, fetch);
                    const float Theta_wavevector = Theta_wavenumber / k;

                    const float directionalSpread
                        = directional_spreading_unified(U10, k_p, k, 0.0f, atan2f(ky, kx));

                    Theta_complete = Theta_wavevector * directionalSpread;
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;
            }
        }
    }   
}

#define N_RESOLUTIONS   8
static const int resolutions[N_RESOLUTIONS] = {8, 16, 32, 64, 128, 256, 512, 1024};

#define N_GENERATORS    4
static const char * names[N_GENERATORS] = {"PM", "JONSWAP", "Donelan", "Unified"};

 typedef void (*GenFunction)(
        const SpectrumGeometry * const,
        const SpectrumParameters * const,
        const double * const,
        fftwf_complex * const
        );

static const GenFunction calls[N_GENERATORS] = {&generatePM, &generateJONSWAP,  &generateDonelan, &generateUnified};

static void GenH0Performance(
    SpectrumGeometry * const geometry,
    const GeneratorSettings * const settings,
    int nIterations
    )
{
    NPTimer * timer = [[ NPTimer alloc ] init ];
    OdGaussianRng * gaussianRNG = odgaussianrng_alloc_init();

    for ( int g = 0; g < N_GENERATORS; g++)
    {
        fprintf(stdout, "%s ", names[g]);

        for ( int r = 0; r < N_RESOLUTIONS; r++ )
        {
            geometry->geometryResolution = resolutions[r];
            geometry->gradientResolution = resolutions[r];

            int necessaryResolution = MAX(geometry->geometryResolution, geometry->gradientResolution);
            const size_t n
                = necessaryResolution * necessaryResolution * geometry->numberOfLods;

            fftwf_complex * H0 = fftwf_alloc_complex(n);
            double * randomNumbers = malloc(sizeof(double) * 2 * n);
            odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * n);

            [ timer update ];
            for ( int i = 0; i < nIterations; i++)
            {
                (*calls[g])(geometry, &(settings->parameters), randomNumbers, H0);
            }
            [ timer update ];
            const double accumulatedTime = [timer frameTime];

            fprintf(stdout, "%.2f ", (accumulatedTime / (double)nIterations) * 1000.0);

            free(randomNumbers);
            fftwf_free(H0);
        }

        fprintf(stdout, "\n");
    }

    odgaussianrng_free(gaussianRNG);
    DESTROY(timer);
}

static void H0Benchmark()
{
    const double goldenRatio = (1.0 + sqrt(5.0)) / 2.0;
    const double goldenRatioLong = 1.0 / goldenRatio;
    const double goldenRatioShort = 1.0 - (1.0 / goldenRatio);

    const double maxSize = 1000; // metre

    SpectrumGeometry geometry;
    geometry.numberOfLods = 1;
    geometry.sizes = malloc(sizeof(double)*geometry.numberOfLods);
    geometry.sizes[0] = maxSize;

    for ( int i = 1; i < geometry.numberOfLods; i++ )
    {
        const double s = geometry.sizes[i-1];
        geometry.sizes[i] = s * goldenRatioShort;
    }

    GeneratorSettings settings;
    settings.parameters.U10 = 10.0;
    settings.parameters.fetch = 100000.0;

    fprintf(stdout, "Spectrum ");
    for ( int r = 0; r < N_RESOLUTIONS; r++)
    {
        fprintf(stdout, "%d ", resolutions[r]);
    }
    fprintf(stdout, "\n");

    GenH0Performance(&geometry, &settings, 50);

    free(geometry.sizes);
}

/*===============================================================================================*/

static void generateHAtTime(
    const SpectrumGeometry * const geometry,
    const fftwf_complex * const H0,
    FrequencySpectrum * const result)
{
    const float time = result->timestamp;

    const int resolution  = MAX(geometry->geometryResolution, geometry->gradientResolution);
    const float fresolution = resolution;

    const int numberOfLods = geometry->numberOfLods;
    const int numberOfLodElements = resolution * resolution;

    const int geometryResolution = geometry->geometryResolution;
    const int gradientResolution = geometry->gradientResolution;

    const int numberOfGeometryElements = geometryResolution * geometryResolution;
    const int numberOfGradientElements = gradientResolution * gradientResolution;

    const int geometryPadding = (resolution - geometryResolution) / 2;
    const int gradientPadding = (resolution - gradientResolution) / 2;

    const IVector2 geometryXRange = {.x = geometryPadding - 1, .y = resolution - geometryPadding };
    const IVector2 geometryYRange = {.x = geometryPadding - 1, .y = resolution - geometryPadding };

    const IVector2 gradientXRange = {.x = gradientPadding - 1, .y = resolution - gradientPadding };
    const IVector2 gradientYRange = {.x = gradientPadding - 1, .y = resolution - gradientPadding };

    const float n = -(fresolution / 2.0f);
    const float m =  (fresolution / 2.0f);

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const float currentSize = geometry->sizes[l];

        const float dkx = MATH_2_MUL_PIf / currentSize;
        const float dky = MATH_2_MUL_PIf / currentSize;

        const int offset = l * numberOfLodElements;
        const int geometryOffset = l * numberOfGeometryElements;
        const int gradientOffset = l * numberOfGradientElements;

        for ( int i = 0; i < resolution; i++ )
        {
            for ( int j = 0; j < resolution; j++ )
            {
                const int indexForK = offset + j + resolution * i;

                const int jConjugateGeometry = MAX(0, (resolution - j - geometryPadding) % geometryResolution);
                const int iConjugateGeometry = MAX(0, (resolution - i - geometryPadding) % geometryResolution);
                const int jConjugateGradient = MAX(0, (resolution - j - gradientPadding) % gradientResolution);
                const int iConjugateGradient = MAX(0, (resolution - i - gradientPadding) % gradientResolution);

                const int indexForConjugateGeometry = offset + jConjugateGeometry + geometryPadding + resolution * (iConjugateGeometry + geometryPadding);
                const int indexForConjugateGradient = offset + jConjugateGradient + gradientPadding + resolution * (iConjugateGradient + gradientPadding);

                const int geometryIndex = geometryOffset + (i - geometryPadding) * geometryResolution + j - geometryPadding;
                const int gradientIndex = gradientOffset + (i - gradientPadding) * gradientResolution + j - gradientPadding;

                const float di = i;
                const float dj = j;

                const float kx = (n + dj) * dkx;
                const float ky = (m - di) * dky;

                //const FVector2 k = {kx, ky};
                //const float omega = omegaf_for_k(&k);
                const float lengthK = sqrtf(kx * kx + ky * ky);
                const float omega = sqrtf(EARTH_ACCELERATIONf * lengthK);
                const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

                // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
                const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

                // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
                const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

                // H0[indexForK] * exp(-i*omega*t)
                const fftwf_complex H0expMinusOmega
                    = { H0[indexForK][0] * expMinusOmega[0] - H0[indexForK][1] * expMinusOmega[1],
                        H0[indexForK][0] * expMinusOmega[1] + H0[indexForK][1] * expMinusOmega[0] };

                const fftwf_complex geometryH0conjugate
                    = { H0[indexForConjugateGeometry][0], -H0[indexForConjugateGeometry][1] };

                const fftwf_complex gradientH0conjugate
                    = { H0[indexForConjugateGradient][0], -H0[indexForConjugateGradient][1] };

                // H0[indexForConjugate] * exp(i*omega*t)
                const fftwf_complex geometryH0expOmega
                    = { geometryH0conjugate[0] * expOmega[0] - geometryH0conjugate[1] * expOmega[1],
                        geometryH0conjugate[0] * expOmega[1] + geometryH0conjugate[1] * expOmega[0] };

                const fftwf_complex gradientH0expOmega
                    = { gradientH0conjugate[0] * expOmega[0] - gradientH0conjugate[1] * expOmega[1],
                        gradientH0conjugate[0] * expOmega[1] + gradientH0conjugate[1] * expOmega[0] };

                // hTilde = H0expOmega + H0expMinusomega            
                const fftwf_complex geometryhTilde
                    = { H0expMinusOmega[0] + geometryH0expOmega[0],
                        H0expMinusOmega[1] + geometryH0expOmega[1] };

                const fftwf_complex gradienthTilde
                    = { H0expMinusOmega[0] + gradientH0expOmega[0],
                        H0expMinusOmega[1] + gradientH0expOmega[1] };

                if ( result->height != NULL
                     && j > geometryXRange.x && j < geometryXRange.y
                     && i > geometryYRange.x && i < geometryYRange.y )
                {
                    result->height[geometryIndex][0] = geometryhTilde[0];
                    result->height[geometryIndex][1] = geometryhTilde[1];
                }

                // first column of a derivative in X direction has to be zero
                // first row of a derivative in Z direction has to be zero
                const float derivativeXScale   = (j == gradientPadding) ? 0.0f : 1.0f;
                const float derivativeZScale   = (i == gradientPadding) ? 0.0f : 1.0f;
                const float displacementXScale = (j == geometryPadding) ? 0.0f : 1.0f;
                const float displacementZScale = (i == geometryPadding) ? 0.0f : 1.0f;

                const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

                if ( j > gradientXRange.x && j < gradientXRange.y
                     && i > gradientYRange.x && i < gradientYRange.y )
                {
                    if ( result->gradient != NULL )
                    {
                        const fftwf_complex gx
                            = {-kx * gradienthTilde[1] * derivativeXScale, kx * gradienthTilde[0] * derivativeXScale};

                        const fftwf_complex gz
                            = {-ky * gradienthTilde[1] * derivativeZScale, ky * gradienthTilde[0] * derivativeZScale};

                        // gx + i*gz
                        result->gradient[gradientIndex][0] = gx[0] - gz[1];
                        result->gradient[gradientIndex][1] = gx[1] + gz[0];
                    }

                    if ( result->displacementXdXdZ != NULL && result->displacementZdXdZ != NULL )
                    {
                        // partial derivatives of dx and dz
                        const float dx_x_term = kx * kx * factor * derivativeXScale;
                        const float dz_z_term = ky * ky * factor * derivativeZScale;
                        const float dx_z_term = ky * kx * factor * derivativeXScale;
                        const float dz_x_term = kx * ky * factor * derivativeZScale;

                        const fftwf_complex dx_x
                            = { dx_x_term * derivativeXScale * gradienthTilde[0],
                                dx_x_term * derivativeXScale * gradienthTilde[1] };

                        const fftwf_complex dx_z
                            = { dx_z_term * derivativeZScale * gradienthTilde[0],
                                dx_z_term * derivativeZScale * gradienthTilde[1] };

                        const fftwf_complex dz_x
                            = { dz_x_term * derivativeXScale * gradienthTilde[0],
                                dz_x_term * derivativeXScale * gradienthTilde[1] };

                        const fftwf_complex dz_z
                            = { dz_z_term * derivativeZScale * gradienthTilde[0],
                                dz_z_term * derivativeZScale * gradienthTilde[1] };

                        result->displacementXdXdZ[gradientIndex][0] = dx_x[0] - dx_z[1];
                        result->displacementXdXdZ[gradientIndex][1] = dx_x[1] + dx_z[0];

                        result->displacementZdXdZ[gradientIndex][0] = dz_x[0] - dz_z[1];
                        result->displacementZdXdZ[gradientIndex][1] = dz_x[1] + dz_z[0];
                    }
                }

                if ( result->displacement != NULL
                     && j > geometryXRange.x && j < geometryXRange.y
                     && i > geometryYRange.x && i < geometryYRange.y )
                {
                    const fftwf_complex dx
                        = { displacementXScale * factor * kx * geometryhTilde[1],
                            displacementXScale * factor * kx * geometryhTilde[0] * -1.0f };

                    const fftwf_complex dz
                         = { displacementZScale * factor * ky * geometryhTilde[1],
                            displacementZScale * factor * ky * geometryhTilde[0] * -1.0f };

                    // dx + i*dz
                    result->displacement[geometryIndex][0] = dx[0] - dz[1];
                    result->displacement[geometryIndex][1] = dx[1] + dz[0];
                }
            }
        }
    }
}

static void swapFrequencySpectrum(
    fftwf_complex * const spectrum,
    int resolution,
    int numberOfLods,
    Quadrants quadrants
    )
{
    fftwf_complex tmp;
    int index, oppositeQuadrantIndex;

    int startX = 0;
    int endX = resolution / 2;
    int startY = 0;
    int endY   = 0;

    switch ( quadrants )
    {
        case Quadrant_1_3:
        {
            startY = 0;
            endY = resolution/2;
            break;
        }

        case Quadrant_2_4:
        {
            startY = resolution/2;
            endY = resolution;
            break;
        }
    }

    const int halfResX = resolution / 2;
    const int halfResY = resolution / 2;

    const int numberOfLodElements = resolution * resolution;

    for ( int l = 0; l < numberOfLods; l++ )
    {
        const int offset = l * numberOfLodElements;

        for ( int i = startX; i < endX; i++ )
        {
            for ( int j = startY; j < endY; j++ )
            {
                index = offset + j + resolution * i;
                oppositeQuadrantIndex = offset + (j + (halfResY * quadrants)) + resolution * (i + halfResX);

                tmp[0] = spectrum[index][0];
                tmp[1] = spectrum[index][1];

                spectrum[index][0] = spectrum[oppositeQuadrantIndex][0];
                spectrum[index][1] = spectrum[oppositeQuadrantIndex][1];

                spectrum[oppositeQuadrantIndex][0] = tmp[0];
                spectrum[oppositeQuadrantIndex][1] = tmp[1];
            }
        }
    }
}

static void GenHPerformance(
    SpectrumGeometry * geometry,
    const GeneratorSettings * const settings,
    int nLods, int nIterations
    )
{
    NPTimer * timer = [[ NPTimer alloc ] init ];
    OdGaussianRng * gaussianRNG = odgaussianrng_alloc_init();

    for ( int l = 1; l <= nLods; l++ )
    {
        geometry->numberOfLods = l;
        fprintf(stdout, "%d ", l);

        for ( int r = 0; r < N_RESOLUTIONS; r++ )
        {
            geometry->geometryResolution = resolutions[r];
            geometry->gradientResolution = resolutions[r];

            int necessaryResolution = MAX(geometry->geometryResolution, geometry->gradientResolution);
            const size_t n
                = necessaryResolution * necessaryResolution * geometry->numberOfLods;

            fftwf_complex * const H0 = fftwf_alloc_complex(n);
            double * randomNumbers = malloc(sizeof(double) * 2 * n);
            odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * n);
            generatePM(geometry, &(settings->parameters), randomNumbers, H0);

            const int numberOfLods = geometry->numberOfLods;
            const int numberOfGeometryElements = geometry->geometryResolution * geometry->geometryResolution;
            const int numberOfGradientElements = geometry->gradientResolution * geometry->gradientResolution;

            FrequencySpectrum result;
            result.height = fftwf_alloc_complex(numberOfLods * numberOfGeometryElements);
            result.gradient = fftwf_alloc_complex(numberOfLods * numberOfGradientElements);
            result.displacement = fftwf_alloc_complex(numberOfLods * numberOfGeometryElements);
            result.displacementXdXdZ = fftwf_alloc_complex(numberOfLods * numberOfGradientElements);
            result.displacementZdXdZ = fftwf_alloc_complex(numberOfLods * numberOfGradientElements);
            result.timestamp = 0.0f;

            [ timer update ];
            for ( int i = 0; i < nIterations; i++)
            {
                generateHAtTime(geometry, H0, &result);

                /*
                swapFrequencySpectrum(result.height, geometry->geometryResolution, l, Quadrant_1_3);
                swapFrequencySpectrum(result.height, geometry->geometryResolution, l, Quadrant_2_4);
                swapFrequencySpectrum(result.displacement, geometry->geometryResolution, l, Quadrant_1_3);
                swapFrequencySpectrum(result.displacement, geometry->geometryResolution, l, Quadrant_2_4);
                swapFrequencySpectrum(result.gradient, geometry->gradientResolution, l, Quadrant_1_3);
                swapFrequencySpectrum(result.gradient, geometry->gradientResolution, l, Quadrant_2_4);
                swapFrequencySpectrum(result.displacementXdXdZ, geometry->gradientResolution, l, Quadrant_1_3);
                swapFrequencySpectrum(result.displacementXdXdZ, geometry->gradientResolution, l, Quadrant_2_4);
                swapFrequencySpectrum(result.displacementZdXdZ, geometry->gradientResolution, l, Quadrant_1_3);
                swapFrequencySpectrum(result.displacementZdXdZ, geometry->gradientResolution, l, Quadrant_2_4);
                */

                result.timestamp += ((float)rand()/(float)(RAND_MAX));
            }
            [ timer update ];
            const double accumulatedTime = [timer frameTime];

            //print_complex_spectrum(geometry->geometryResolution, result.height);
            //print_complex_spectrum(geometry->geometryResolution, result.height);

            fprintf(stdout, "%.3f ", (accumulatedTime / (double)nIterations) * 1000.0);

            fftwf_free(result.height);
            fftwf_free(result.gradient);
            fftwf_free(result.displacement);
            fftwf_free(result.displacementXdXdZ);
            fftwf_free(result.displacementZdXdZ);
            free(randomNumbers);
            fftwf_free(H0);
        }

        fprintf(stdout, "\n");
    }

    odgaussianrng_free(gaussianRNG);
    DESTROY(timer);
}

static void HBenchmark()
{
    const double goldenRatio = (1.0 + sqrt(5.0)) / 2.0;
    const double goldenRatioLong = 1.0 / goldenRatio;
    const double goldenRatioShort = 1.0 - (1.0 / goldenRatio);

    const double maxSize = 1000; // metre

    SpectrumGeometry geometry;
    geometry.numberOfLods = 4;
    geometry.sizes = malloc(sizeof(double)*geometry.numberOfLods);
    geometry.sizes[0] = maxSize;

    for ( int i = 1; i < geometry.numberOfLods; i++ )
    {
        const double s = geometry.sizes[i-1];
        geometry.sizes[i] = s * goldenRatioShort;
    }

    GeneratorSettings settings;
    settings.generatorType = PiersonMoskowitz;
    settings.parameters.U10 = 10.0;
    settings.parameters.fetch = 100000.0;

    fprintf(stdout, "#Lods ");
    for ( int r = 0; r < N_RESOLUTIONS; r++)
    {
        fprintf(stdout, "%d ", resolutions[r]);
    }
    fprintf(stdout, "\n");

    GenHPerformance(&geometry, &settings, 4, 100);

    free(geometry.sizes);   
}

static void FFTWPerformance(
    fftwf_plan * plans,
    int nIterations
    )
{
    NPTimer * timer = [[ NPTimer alloc ] init ];

    for ( int r = 0; r < N_RESOLUTIONS; r++ )
    {
        const size_t numberOfElements = resolutions[r] * resolutions[r];

        fftwf_complex * source = fftwf_alloc_complex(numberOfElements);
        fftwf_complex * target = fftwf_alloc_complex(numberOfElements);

        memset(source, 0, sizeof(fftwf_complex) * numberOfElements);
        memset(target, 0, sizeof(fftwf_complex) * numberOfElements);

        [ timer update ];

        for ( int i = 0; i < nIterations; i++ )
        {
            fftwf_execute_dft(
                plans[r],
                source,
                target
                );
        }

        [ timer update ];
        const double accumulatedTime = [timer frameTime];

        fprintf(stdout, "%.4f ", (accumulatedTime / (double)nIterations) * 1000.0);

        fftwf_free(target);
        fftwf_free(source);
    }

    fprintf(stdout, "\n");

    DESTROY(timer);
}

static const char * wisdomFilename = "benchmark.wisdom";

static void FFTWBenchmark()
{
    fftwf_plan complexPlans[N_RESOLUTIONS];
    const int wisdomFound = fftwf_import_wisdom_from_filename(wisdomFilename);

    for ( int i = 0; i < N_RESOLUTIONS; i++)
    {
        const size_t arraySize = resolutions[i] * resolutions[i];

        fftwf_complex * source = fftwf_alloc_complex(arraySize);
        fftwf_complex * target = fftwf_alloc_complex(arraySize);

        memset(source, rand(), sizeof(fftwf_complex) * arraySize);
        memset(target, rand(), sizeof(fftwf_complex) * arraySize);

        complexPlans[i]
            = fftwf_plan_dft_2d(resolutions[i],
                                resolutions[i],
                                source,
                                target,
                                FFTW_BACKWARD,
                                FFTW_EXHAUSTIVE);

        fftwf_free(source);
        fftwf_free(target);
    }

    if (!wisdomFound)
    {
        fftwf_export_wisdom_to_filename(wisdomFilename);
    }

    FFTWPerformance(complexPlans, 10000);

    for ( int i = 0; i < N_RESOLUTIONS; i++ )
    {
        if ( complexPlans[i] != NULL )
        {
            fftwf_destroy_plan(complexPlans[i]);
        }
    }

    fftwf_forget_wisdom();
    fftwf_cleanup();
}

/*===============================================================================================*/

int main(int argc, char **argv)
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    //H0Benchmark();
    //HBenchmark();
    FFTWBenchmark();

    DESTROY(pool);

    return EXIT_SUCCESS;
}
