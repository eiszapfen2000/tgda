#import "Foundation/NSException.h"
#import "Core/Timer/NPTimer.h"
#import "ODConstants.h"
#import "ODEnergy.h"
#import "ODFrequencySpectrumFloat.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

#define GRAVITY_CAPILLARY_PEAK_OMEGA    61.0f  // ceil(sqrt(9.81*((2*pi)/0.017)))
#define GRAVITY_CAPILLARY_PEAK_K        370.0f // ceil((2*pi)/0.017)

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

@interface ODFrequencySpectrumFloat (Private)

- (void) generateH0:(BOOL)force;
- (void) generatePMSpectrum;
- (void) generateJONSWAPSpectrum;
- (void) generateDonelanSpectrum;
- (void) generateUnifiedSpectrum;

@end

@implementation ODFrequencySpectrumFloat (Private)

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

    float mss = 0.0f;

    /*
    for ( float k = 0.001f; k < GRAVITY_CAPILLARY_PEAK_K; k = k * 1.001f )
    {
        // deep water dispersion relation
        const float omega = sqrtf(k * EARTH_ACCELERATIONf);

        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        const float Theta = energy_pm_wave_frequency(omega, U10);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }

    printf("PM mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);

    mss = 0.0f;
    */

    for ( float omega = 0.001f; omega < GRAVITY_CAPILLARY_PEAK_OMEGA; omega = omega * 1.001f )
    {
        const float nextOmega = omega * 1.001f;
        // deep water dispersion relation
        const float k = (omega * omega) / EARTH_ACCELERATIONf;
        const float nextk = (nextOmega * nextOmega) / EARTH_ACCELERATIONf;

        const float kSquare = k * k;
        const float dk = nextk - k;

        // eq A3
        const float Theta = energy_pm_wave_frequency(omega, U10);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }


    printf("PM mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);
}

- (void) generateJONSWAPSpectrum
{
    const OdJONSWAPGeneratorSettings settings
        = currentGeneratorSettings.jonswap;

    const IVector2 resolution  = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const float U10   = settings.U10;
    const float fetch = settings.fetch;

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    const float omega_p = peak_energy_wave_frequency_jonswap(U10, fetch);

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
                    const float Theta = energy_jonswap_wave_frequency(omega, U10, fetch);
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

    float mss = 0.0f;

    /*
    for ( float k = 0.001f; k < GRAVITY_CAPILLARY_PEAK_K; k = k * 1.001f )
    {
        // deep water dispersion relation
        const float omega = sqrtf(k * EARTH_ACCELERATIONf);

        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        const float Theta = energy_jonswap_wave_frequency(omega, U10, fetch);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }

    printf("J mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);

    mss = 0.0f;
    */

    for ( float omega = 0.001f; omega < GRAVITY_CAPILLARY_PEAK_OMEGA; omega = omega * 1.001f )
    {
        const float nextOmega = omega * 1.001f;
        // deep water dispersion relation
        const float k = (omega * omega) / EARTH_ACCELERATIONf;
        const float nextk = (nextOmega * nextOmega) / EARTH_ACCELERATIONf;

        const float kSquare = k * k;
        const float dk = nextk - k;

        // eq A3
        const float Theta = energy_jonswap_wave_frequency(omega, U10, fetch);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }

    printf("J  mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);
}

- (void) generateDonelanSpectrum
{
    const OdDonelanGeneratorSettings settings
        = currentGeneratorSettings.donelan;

    const IVector2 resolution  = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const float U10   = settings.U10;
    const float fetch = settings.fetch;

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    const float omega_p = peak_energy_wave_frequency_donelan(U10, fetch);

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
                    const float Theta = energy_donelan_wave_frequency(omega, U10, fetch);
                    // convert Theta from wave frequency domain to wave number domain
                    const float Theta_wavenumber = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);
                    // convert Theta from wave number domain to wave vector domain
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

        //printf("\n");
    }

    float mss = 0.0f;

    /*
    for ( float k = 0.001f; k < GRAVITY_CAPILLARY_PEAK_K; k = k * 1.001f )
    {
        // deep water dispersion relation
        const float omega = sqrtf(k * EARTH_ACCELERATIONf);

        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        const float Theta = energy_donelan_wave_frequency(omega, U10, fetch);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }

    printf("D mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);

    mss = 0.0f;
    */

    for ( float omega = 0.001f; omega < GRAVITY_CAPILLARY_PEAK_OMEGA; omega = omega * 1.001f )
    {
        const float nextOmega = omega * 1.001f;
        // deep water dispersion relation
        const float k = (omega * omega) / EARTH_ACCELERATIONf;
        const float nextk = (nextOmega * nextOmega) / EARTH_ACCELERATIONf;

        const float kSquare = k * k;
        const float dk = nextk - k;

        // eq A3
        const float Theta = energy_donelan_wave_frequency(omega, U10, fetch);
        const float sk = Theta * 0.5f * (EARTH_ACCELERATIONf / omega);

        // eq A6
        mss += kSquare * sk * dk;
    }


    printf("D  mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);
}

- (void) generateUnifiedSpectrum
{
    const OdJONSWAPGeneratorSettings settings
        = currentGeneratorSettings.jonswap;

    const IVector2 resolution  = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const float U10   = settings.U10;
    const float fetch = settings.fetch;

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    const float k_p = peak_energy_wave_number_unified(U10, fetch);

    float mssX  = 0.0;
    float mssY  = 0.0;
    float mssXY = 0.0;

    float mink =  FLT_MAX;
    float maxk = -FLT_MAX;

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

        //printf("%f %f %f\n", kMinX, kMinY, kMin);

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

                //printf("%f ", k);

                // Theta in wave vector domain
                float Theta_complete = 0.0f;

                if (k > kMin)
                {
                    const float Theta_wavenumber = energy_unified_wave_number(k, U10, fetch);
                    const float Theta_wavevector = Theta_wavenumber / k;

                    const float directionalSpread
                        = directional_spreading_unified(U10, k_p, k, 0.0f, atan2f(ky, kx));

                    Theta_complete = Theta_wavevector * directionalSpread;

                    mssX  += (kx * kx) * (dkx * dky) * Theta_complete;
                    mssY  += (ky * ky) * (dkx * dky) * Theta_complete;
                    mssXY += (kx * kx + ky * ky) * (dkx * dky) * Theta_complete;
                }

                const float amplitude = sqrtf(2.0f * Theta_complete * dkx * dky);

                baseSpectrum[index] = Theta_complete;
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * amplitude * 0.5f;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * amplitude * 0.5f;

                mink = MIN(mink, k);
                maxk = MAX(maxk, k);

                //printf("%+f %+fi ", H0[index][0], H0[index][1]);
            }

            //printf("\n");
        }

        //printf("\n");
    }

    float mss = 0.0f;

    for ( float k = 0.001f; k < GRAVITY_CAPILLARY_PEAK_K; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        const float sk = energy_unified_wave_number(k, U10, fetch);

        // eq A6
        mss += kSquare * sk * dk;
    }

    printf("U  mssx: %f mssy: %f mssxy: %f mss: %f\n", mssX, mssY, mssXY, mss);
}

- (void) generateH0:(BOOL)force
{
    if ( geometries_equal(&currentGeometry, &lastGeometry) == true
         && generator_settings_equal(&currentGeneratorSettings, &lastGeneratorSettings) == true
         && force == NO )
    {
        return;
    }

    BOOL generateRandomNumbers = force;

    if ( geometries_equal_resolution(&currentGeometry, &lastGeometry) == false
         || geometries_equal_lods(&currentGeometry, &lastGeometry) == false )
    {
        IVector2 necessaryResolution;
        necessaryResolution.x = MAX(currentGeometry.geometryResolution.x, currentGeometry.gradientResolution.x);
        necessaryResolution.y = MAX(currentGeometry.geometryResolution.y, currentGeometry.gradientResolution.y);

        if ( currentGeometry.numberOfLods != H0Lods
             || necessaryResolution.x != H0Resolution.x
             || necessaryResolution.y != H0Resolution.y )
        {
            FFTW_SAFE_FREE(H0);
            SAFE_FREE(randomNumbers);

            const size_t n
                = necessaryResolution.x * necessaryResolution.y * currentGeometry.numberOfLods;

            H0 = fftwf_alloc_complex(n);
            randomNumbers = ALLOC_ARRAY(double, 2 * n);

            H0Lods = currentGeometry.numberOfLods;
            H0Resolution = necessaryResolution;
            generateRandomNumbers = YES;
        }
    }

    if ( generateRandomNumbers == YES )
    {
        odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * H0Lods * H0Resolution.x * H0Resolution.y);
    }

    switch ( currentGeneratorSettings.generatorType )
    {
        case PiersonMoskowitz:
        {
            [ self generatePMSpectrum ];
            break;
        }

        case JONSWAP:
        {
            [ self generateJONSWAPSpectrum ];
            break;
        }

        case Donelan:
        {
            [ self generateDonelanSpectrum ];
            break;
        }

        case Unified:
        {
            [ self generateUnifiedSpectrum ];
            break;
        }

        default:
        {
            NSAssert(NO, @"Unknown generator type");
            break;
        }
    }
}

@end

static NPTimer * timer = nil;

@implementation ODFrequencySpectrumFloat

+ (void) initialize
{
    timer = [[ NPTimer alloc ] initWithName:@"Spectrum Timer" ];
}

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum Float" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    H0 = NULL;
    baseSpectrum = NULL;
    randomNumbers = NULL;
    H0Resolution = iv2_zero();
    H0Lods = 0;

    gaussianRNG = odgaussianrng_alloc_init();

    maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;

    lastGeometry    = geometry_max();
    currentGeometry = geometry_zero();
    lastGeneratorSettings    = generator_settings_max();
    currentGeneratorSettings = generator_settings_zero();

    return self;
}

- (void) dealloc
{
    SAFE_FREE(lastGeometry.sizes);
    SAFE_FREE(currentGeometry.sizes);

    FFTW_SAFE_FREE(H0);
    FFTW_SAFE_FREE(baseSpectrum);
    SAFE_FREE(randomNumbers);
    odgaussianrng_free(gaussianRNG);

    [ super dealloc ];
}

- (OdFrequencySpectrumFloat) generateHAtTime:(const float)time
{
    const IVector2 resolution = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t numberOfLods = H0Lods;
    const int32_t numberOfLodElements = resolution.x * resolution.y;

    const IVector2 geometryResolution = currentGeometry.geometryResolution;
    const IVector2 gradientResolution = currentGeometry.gradientResolution;

    const int32_t numberOfGeometryElements = geometryResolution.x * geometryResolution.y;
    const int32_t numberOfGradientElements = gradientResolution.x * gradientResolution.y;

    OdFrequencySpectrumFloat result = frequency_spectrum_zero();
    result.timestamp = time;

    frequency_spectrum_init_with_geometry_and_options(
        &result, &currentGeometry,
        currentGeneratorSettings.options
        );

    const IVector2 geometryPadding
        = { .x = (H0Resolution.x - geometryResolution.x) / 2, .y = (H0Resolution.y - geometryResolution.y) / 2 };

    const IVector2 gradientPadding
        = { .x = (H0Resolution.x - gradientResolution.x) / 2, .y = (H0Resolution.y - gradientResolution.y) / 2 };

    const IVector2 geometryXRange = {.x = geometryPadding.x - 1, .y = resolution.x - geometryPadding.x };
    const IVector2 geometryYRange = {.x = geometryPadding.y - 1, .y = resolution.y - geometryPadding.y };

    const IVector2 gradientXRange = {.x = gradientPadding.x - 1, .y = resolution.x - gradientPadding.x };
    const IVector2 gradientYRange = {.x = gradientPadding.y - 1, .y = resolution.y - gradientPadding.y };

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    for ( int32_t l = 0; l < numberOfLods; l++ )
    {
        const FVector2 currentSize = fv2_v_from_v2(&currentGeometry.sizes[l]);

        const float dkx = MATH_2_MUL_PIf / currentSize.x;
        const float dky = MATH_2_MUL_PIf / currentSize.y;

        const int32_t offset = l * numberOfLodElements;
        const int32_t geometryOffset = l * numberOfGeometryElements;
        const int32_t gradientOffset = l * numberOfGradientElements;

        for ( int32_t i = 0; i < resolution.y; i++ )
        {
            for ( int32_t j = 0; j < resolution.x; j++ )
            {
                const int32_t indexForK = offset + j + resolution.x * i;

                const int32_t jConjugateGeometry = MAX(0, (resolution.x - j - geometryPadding.x) % geometryResolution.x);
                const int32_t iConjugateGeometry = MAX(0, (resolution.y - i - geometryPadding.y) % geometryResolution.y);
                const int32_t jConjugateGradient = MAX(0, (resolution.x - j - gradientPadding.x) % gradientResolution.x);
                const int32_t iConjugateGradient = MAX(0, (resolution.y - i - gradientPadding.y) % gradientResolution.y);

                const int32_t indexForConjugateGeometry = offset + jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
                const int32_t indexForConjugateGradient = offset + jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

                const int32_t geometryIndex = geometryOffset + (i - geometryPadding.y) * geometryResolution.x + j - geometryPadding.x;
                const int32_t gradientIndex = gradientOffset + (i - gradientPadding.y) * gradientResolution.x + j - gradientPadding.x;

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

                //printf("%+f %+fi ", expOmega[0], expOmega[1]);

                /* complex multiplication
                   x = a + i*b
                   y = c + i*d
                   xy = (ac-bd) + i(ad+bc)

                   b = 0
                   x = a + i*0
                   y = c + i*d
                   xy = (ac-0d) + i(ad+0c)
                      = ac + i(ad)

                   a = 0
                   x = 0 + i*b
                   y = c + i*d
                   xy = (0c-bd) + i(0d+bc)
                      = (-bd) + i(bc)
                */

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

                /* complex addition
                   x = a + i*b
                   y = c + i*d
                   x+y = (a+c)+i(b+d)
                */

                // hTilde = H0expOmega + H0expMinusomega            
                const fftwf_complex geometryhTilde
                    = { H0expMinusOmega[0] + geometryH0expOmega[0],
                        H0expMinusOmega[1] + geometryH0expOmega[1] };

                const fftwf_complex gradienthTilde
                    = { H0expMinusOmega[0] + gradientH0expOmega[0],
                        H0expMinusOmega[1] + gradientH0expOmega[1] };

                //printf("%+f %+fi ", geometryhTilde[0], geometryhTilde[1]);


                //if ( indexForK >= geometryStartIndex && indexForK <= geometryEndIndex )
                if ( result.height != NULL
                     && j > geometryXRange.x && j < geometryXRange.y
                     && i > geometryYRange.x && i < geometryYRange.y )
                {
                    result.height[geometryIndex][0] = geometryhTilde[0];
                    result.height[geometryIndex][1] = geometryhTilde[1];
                }

                // i * kx
                /*
                x = 0  + i*1
                y = kx + i*0
                xy = (0*k - 1*0) + i*(0*0+1*kx)
                   = 0 + i*kx
                */

                // i * kx * H
                /*
                x = 0 + i*kx
                H = c + i*d
                xH = (0*c - kx*d) + i*(0*d+kx*c)
                */

                // first column of a derivative in X direction has to be zero
                // first row of a derivative in Z direction has to be zero
                const float derivativeXScale   = (j == gradientPadding.x) ? 0.0f : 1.0f;
                const float derivativeZScale   = (i == gradientPadding.y) ? 0.0f : 1.0f;
                const float displacementXScale = (j == geometryPadding.x) ? 0.0f : 1.0f;
                const float displacementZScale = (i == geometryPadding.y) ? 0.0f : 1.0f;

                const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

                if ( j > gradientXRange.x && j < gradientXRange.y
                     && i > gradientYRange.x && i < gradientYRange.y )
                {
                    if ( result.gradient != NULL )
                    {
                        const fftwf_complex gx
                            = {-kx * gradienthTilde[1] * derivativeXScale, kx * gradienthTilde[0] * derivativeXScale};

                        const fftwf_complex gz
                            = {-ky * gradienthTilde[1] * derivativeZScale, ky * gradienthTilde[0] * derivativeZScale};

                        // gx + i*gz
                        result.gradient[gradientIndex][0] = gx[0] - gz[1];
                        result.gradient[gradientIndex][1] = gx[1] + gz[0];
                    }

                    if ( result.displacementXdXdZ != NULL && result.displacementZdXdZ != NULL )
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

                        result.displacementXdXdZ[gradientIndex][0] = dx_x[0] - dx_z[1];
                        result.displacementXdXdZ[gradientIndex][1] = dx_x[1] + dx_z[0];

                        result.displacementZdXdZ[gradientIndex][0] = dz_x[0] - dz_z[1];
                        result.displacementZdXdZ[gradientIndex][1] = dz_x[1] + dz_z[0];
                    }
                }

                // -i * kx/|k| * H
                /*
                x  = 0 + i*(-kx/|k|)
                H  = c + i*d
                xH = (0*c - (-kx/|k| * d)) + i*(0*d + (-kx/|k| * c))
                   = d*kx/|k| + i*(-c*kx/|k|)
                */

                
                if ( result.displacement != NULL
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
                    result.displacement[geometryIndex][0] = dx[0] - dz[1];
                    result.displacement[geometryIndex][1] = dx[1] + dz[0];
                }
            }

            //printf("\n");
        }
    }

    return result;
}

- (OdFrequencySpectrumFloat) generateTimeIndependentH
{
    return [ self generateHAtTime:1.0f ];
}

/*
Frequeny Spectrum Quadrant Layout

---------
| 1 | 2 |
---------
| 4 | 3 |
---------

*/

/*
If I want to generate less data and use a complex 2 real transform
I need to take the quadrant swapping into account, it's not enough
to simply generate data for quadrant 1 and 2.
Basically I need quadrant 4 and 3, but quadrant 3 has to be moved
to quadrant 4's left side.
Either screw around with two for loops or choose k the
right way.
*/

- (void) swapFrequencySpectrum:(fftwf_complex *)spectrum
                    resolution:(IVector2)resolution
                  numberOfLods:(uint32_t)numberOfLods
                     quadrants:(ODQuadrants)quadrants
{
    fftwf_complex tmp;
    int32_t index, oppositeQuadrantIndex;

    int32_t startX = 0;
    int32_t endX = resolution.x / 2;
    int32_t startY = 0;
    int32_t endY   = 0;

    switch ( quadrants )
    {
        case ODQuadrant_1_3:
        {
            startY = 0;
            endY = resolution.y/2;
            break;
        }

        case ODQuadrant_2_4:
        {
            startY = resolution.y/2;
            endY = resolution.y;
            break;
        }
    }

    const int32_t halfResX = resolution.x / 2;
    const int32_t halfResY = resolution.y / 2;

    const int32_t numberOfLodElements = resolution.x * resolution.y;

    for ( uint32_t l = 0; l < numberOfLods; l++ )
    {
        const int32_t offset = l * numberOfLodElements;

        for ( int32_t i = startX; i < endX; i++ )
        {
            for ( int32_t j = startY; j < endY; j++ )
            {
                index = offset + j + resolution.y * i;
                oppositeQuadrantIndex = offset + (j + (halfResY * quadrants)) + resolution.y * (i + halfResX);

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

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumWithGeometry:(OdSpectrumGeometry)geometry
                            generator:(OdGeneratorSettings)generatorSettings
                               atTime:(float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
{
    geometry_copy(&geometry, &currentGeometry);
    currentGeneratorSettings = generatorSettings;

    // static spectrum generation
    [ timer update ];
    [ self generateH0:generateBaseGeometry ];
    [ timer update ];
    const double H0Time = [ timer frameTime ];

    // animated spectrum generation
    [ timer update ];
    OdFrequencySpectrumFloat result = [ self generateHAtTime:time ];
    [ timer update ];
    const double HTime =  [ timer frameTime ];

    // quadrant swapping
    [ timer update ];

    if ( result.height != NULL )
    {
        [ self swapFrequencySpectrum:result.height
                          resolution:currentGeometry.geometryResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.height
                          resolution:currentGeometry.geometryResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.gradient != NULL )
    {
        [ self swapFrequencySpectrum:result.gradient
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradient
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacement != NULL )
    {
        [ self swapFrequencySpectrum:result.displacement
                          resolution:currentGeometry.geometryResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacement
                          resolution:currentGeometry.geometryResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementXdXdZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementXdXdZ
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementXdXdZ
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementZdXdZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementZdXdZ
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementZdXdZ
                          resolution:currentGeometry.gradientResolution
                        numberOfLods:currentGeometry.numberOfLods
                           quadrants:ODQuadrant_2_4 ];
    }

    [ timer update ];
    const double quadrantSwapTime = [ timer frameTime ];

    result.timings[H0_GEN_TIMING] = H0Time;
    result.timings[H_GEN_TIMING]  = HTime;
    result.timings[QSWAP_TIMING] = quadrantSwapTime;

    if ( baseSpectrum != NULL )
    {
        result.baseSpectrum = baseSpectrum;
        result.maxMeanSlopeVariance = maxMeanSlopeVariance;
        result.effectiveMeanSlopeVariance = effectiveMeanSlopeVariance;

        baseSpectrum = NULL;
        maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;
    }

    geometry_copy(&currentGeometry, &lastGeometry);
    lastGeneratorSettings = currentGeneratorSettings;

    return result;
}

@end

