#import "Foundation/NSException.h"
#import "Core/Timer/NPTimer.h"
#import "ODConstants.h"
#import "ODAmplitude.h"
#import "ODFrequencySpectrumFloat.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

@interface ODFrequencySpectrumFloat (Private)

- (void) generateH0:(BOOL)force;
- (void) generatePhillipsSpectrum;
- (void) generateUnifiedSpectrum;

@end

@implementation ODFrequencySpectrumFloat (Private)

- (void) generateUnifiedSpectrum
{
    const ODUnifiedGeneratorSettings settings
        = currentGeneratorSettings.unified;

    const IVector2 resolution  = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const float U10   = settings.U10;
    const float Omega = settings.Omega;

    const FVector2 maxSize = fv2_v_from_v2(&currentGeometry.sizes[0]);

    const float A = currentGeneratorSettings.spectrumScale / (maxSize.x * maxSize.y);

    const float n = -(fresolution.x / 2.0f);
    const float m =  (fresolution.y / 2.0f);

    float varianceX  = 0.0;
    float varianceY  = 0.0;
    float varianceXY = 0.0;

    for ( int32_t l = 0; l < numberOfLods; l++ )
    {
        printf("LOD %d\n", l);

        const FVector2 lastSize
            = ( l == 0 ) ? fv2_zero() : fv2_v_from_v2(&currentGeometry.sizes[l - 1]);

        const FVector2 currentSize = fv2_v_from_v2(&currentGeometry.sizes[l]);

        const float dkx = MATH_2_MUL_PIf / currentSize.x;
        const float dky = MATH_2_MUL_PIf / currentSize.y;

        const float kMin = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution.x ) / lastSize.x );

        //printf("%f %f %f %f %f\n", currentSize.x, currentSize.y, lastSize.x, lastSize.y, kMin);

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

                const float kx = (n + dj) * dkx;
                const float ky = (m - di) * dky;

//                printf("%d %d\n", j, i);

                const FVector2 k = {kx, ky};
                const float t = amplitudef_unified_cartesian(k, kMin, A, U10, Omega);
                const float s = MAX(0.0f, t);
                const float a = sqrtf(s);

                varianceX  += (kx * kx) * (dkx * dky) * s;
                varianceY  += (ky * ky) * (dkx * dky) * s;
                varianceXY += (kx * kx + ky * ky) * (dkx * dky) * s;

                baseSpectrum[index] = s;
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
            }
        }
    }

    float mss = 0.0f;

    for ( float k = 0.001f; k < 1000.0f; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        float sk = amplitudef_unified_cartesian_omnidirectional(k, 0.0f, A, U10, Omega);

        // eq A6
        mss += kSquare * sk * dk;
    }

    maxMeanSlopeVariance = mss;
    effectiveMeanSlopeVariance = varianceXY;
}

- (void) generatePhillipsSpectrum
{
    const ODPhillipsGeneratorSettings settings
        = currentGeneratorSettings.phillips;

    const IVector2 resolution   = H0Resolution;
    const FVector2 fresolution = fv2_v_from_iv2(&resolution);

    const int32_t  numberOfLods = H0Lods;
    const int32_t  numberOfLodElements = resolution.x * resolution.y;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(numberOfLods * numberOfLodElements);

    const FVector2 maxSize = fv2_v_from_v2(&currentGeometry.sizes[0]);

    const FVector2 windDirection = fv2_v_from_v2(&settings.windDirection);
    const FVector2 windDirectionNormalised = fv2_v_normalised(&windDirection);
    const float    windSpeed = settings.windSpeed;
    const float    dampening = settings.dampening;

    assert(dampening < 1.0f);

    const float A = currentGeneratorSettings.spectrumScale / (maxSize.x * maxSize.y);
    const float L = (windSpeed * windSpeed) / EARTH_ACCELERATIONf;
    const float l = dampening * L;

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    float varianceX  = 0.0;
    float varianceY  = 0.0;
    float varianceXY = 0.0;

    for ( int32_t l = 0; l < numberOfLods; l++ )
    {
        printf("LOD %d\n", l);

        const FVector2 lastSize
            = ( l == 0 ) ? fv2_zero() : fv2_v_from_v2(&currentGeometry.sizes[l - 1]);

        const FVector2 currentSize = fv2_v_from_v2(&currentGeometry.sizes[l]);

        const float dkx = MATH_2_MUL_PIf / currentSize.x;
        const float dky = MATH_2_MUL_PIf / currentSize.y;

        const float kMin = ( l == 0 ) ? 0.0f : (( MATH_PI * fresolution.x ) / lastSize.x );

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

                const float kx = (n + dj) * dkx;
                const float ky = (m - di) * dky;

                const FVector2 k = {kx, ky};
                const float s = amplitudef_phillips_cartesian(windDirectionNormalised, k, kMin, A, L, l);
                const float a = sqrtf(s);

                varianceX  += (kx * kx) * (dkx * dky) * s;
                varianceY  += (ky * ky) * (dkx * dky) * s;
                varianceXY += (kx * kx + ky * ky) * (dkx * dky) * s;

                baseSpectrum[index] = s;
                H0[index][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
                H0[index][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
            }
        }
    }

    float mss = 0.0f;

    for ( float k = 0.001f; k < 1000.0f; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        float sk = amplitudef_phillips_cartesian_omnidirectional(k, 0.0f, A, L, l);

        // eq A6
        mss += kSquare * sk * dk;
    }

    maxMeanSlopeVariance = mss;
    effectiveMeanSlopeVariance = varianceXY;

/*
    const float deltaVariance = mss - varianceXY;

    const int32_t slopeVarianceResolution = 4;
    const float divisor = (float)(slopeVarianceResolution - 1);
    const float AA = A;

    for ( int32_t c = 0; c < slopeVarianceResolution; c++ )
    {
        for ( int32_t b = 0; b < slopeVarianceResolution; b++ )
        {
            for ( int32_t a = 0; a < slopeVarianceResolution; a++ )
            {
                const float fa = a;
                const float fb = b;
                const float fc = c;
                float A = powf(a / divisor, 4.0f);
                float C = powf(c / divisor, 4.0f);
                float B = (2.0f * b / divisor - 1.0) * sqrt(A * C);

                //NSLog(@"1 %d %d %d %f %f %f", a, b, c, A, B, C);

                A = -0.5f * A;
                B = -B;
                C = -0.5f * C;

                //NSLog(@"2 %d %d %d %f %f %f", a, b, c, A, B, C);

                float lvarianceX = deltaVariance;
                float lvarianceY = deltaVariance;

                for ( int32_t i = 0; i < resolution.y; i++ )
                {
                    for ( int32_t j = 0; j < resolution.x; j++ )
                    {
                        const float di = i;
                        const float dj = j;

                        const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
                        const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

                        const FVector2 k = {kx, ky};
                        const float w = 1.0f - exp(A * k.x * k.x + B * k.x * k.y + C * k.y * k.y);
                        const float s = amplitudef_cartesian(windDirectionNormalised, k, AA, L, l);

                        lvarianceX += ((kx * kx * w * w) * (dkx * dky) * s);
                        lvarianceY += ((ky * ky * w * w) * (dkx * dky) * s);

                        //NSLog(@"%f %f", lvarianceX, lvarianceY);
                    }
                }

                //NSLog(@"%d %d %d %f %f %f", a, b, c, lvarianceX, lvarianceY, lvarianceX + lvarianceY);
            }
        }
    }
    */
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

    if ( geometries_equal_resolution(&currentGeometry, &lastGeometry) == false )
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
        case Phillips:
        {
            [ self generatePhillipsSpectrum ];
            break;
        }

        case Unified:
        {
            [ self generateUnifiedSpectrum ];
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

    lastGeometry.numberOfLods = UINT32_MAX;
    lastGeometry.geometryResolution = iv2_max();
    lastGeometry.gradientResolution = iv2_max();
    lastGeometry.sizes = NULL;

    currentGeometry.numberOfLods = 0;
    currentGeometry.geometryResolution = iv2_zero();
    currentGeometry.gradientResolution = iv2_zero();
    currentGeometry.sizes = NULL;

    lastGeneratorSettings.phillips.windDirection = v2_max();
    lastGeneratorSettings.phillips.windSpeed = DBL_MAX;
    lastGeneratorSettings.phillips.dampening = DBL_MAX;

    currentGeneratorSettings.phillips.windDirection = v2_zero();
    currentGeneratorSettings.phillips.windSpeed = 0.0;
    currentGeneratorSettings.phillips.dampening = 0.0;

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
    const IVector2 geometryResolution = currentGeometry.geometryResolution;
    const IVector2 gradientResolution = currentGeometry.gradientResolution;
    const FVector2 size = (FVector2){currentGeometry.sizes[0].x, currentGeometry.sizes[0].y};

	fftwf_complex * frequencySpectrum
        = fftwf_alloc_complex(geometryResolution.x * geometryResolution.y);

	fftwf_complex * gradient
        = fftwf_alloc_complex(gradientResolution.x * gradientResolution.y);

    fftwf_complex * displacement //= NULL;
        = fftwf_alloc_complex(geometryResolution.x * geometryResolution.y);

    fftwf_complex * displacementXdXdZ
        = fftwf_alloc_complex(gradientResolution.x * gradientResolution.y);

    fftwf_complex * displacementZdXdZ
        = fftwf_alloc_complex(gradientResolution.x * gradientResolution.y);

    const IVector2 geometryPadding
        = { .x = (H0Resolution.x - geometryResolution.x) / 2, .y = (H0Resolution.y - geometryResolution.y) / 2 };

    const IVector2 gradientPadding
        = { .x = (H0Resolution.x - gradientResolution.x) / 2, .y = (H0Resolution.y - gradientResolution.y) / 2 };

    const IVector2 geometryXRange = {.x = geometryPadding.x - 1, .y = resolution.x - geometryPadding.x };
    const IVector2 geometryYRange = {.x = geometryPadding.y - 1, .y = resolution.y - geometryPadding.y };

    const IVector2 gradientXRange = {.x = gradientPadding.x - 1, .y = resolution.x - gradientPadding.x };
    const IVector2 gradientYRange = {.x = gradientPadding.y - 1, .y = resolution.y - gradientPadding.y };

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t indexForK = j + resolution.x * i;

            const int32_t jConjugateGeometry = MAX(0, (resolution.x - j - geometryPadding.x) % geometryResolution.x);
            const int32_t iConjugateGeometry = MAX(0, (resolution.y - i - geometryPadding.y) % geometryResolution.y);
            const int32_t jConjugateGradient = MAX(0, (resolution.x - j - gradientPadding.x) % gradientResolution.x);
            const int32_t iConjugateGradient = MAX(0, (resolution.y - i - gradientPadding.y) % gradientResolution.y);

            const int32_t indexForConjugateGeometry = jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
            const int32_t indexForConjugateGradient = jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

            const int32_t geometryIndex = (i - geometryPadding.y) * geometryResolution.x + j - geometryPadding.x;
            const int32_t gradientIndex = (i - gradientPadding.y) * gradientResolution.x + j - gradientPadding.x;

            const float di = i;
            const float dj = j;

            const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

            //const FVector2 k = {kx, ky};
            //const float omega = omegaf_for_k(&k);
            const float lengthK = sqrtf(kx * kx + ky * ky);
            const float omega = sqrtf(EARTH_ACCELERATIONf * lengthK);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

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

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1],
                    H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0] };

            const fftwf_complex geometryH0conjugate
                = { H0[indexForConjugateGeometry][0], -H0[indexForConjugateGeometry][1] };

            const fftwf_complex gradientH0conjugate
                = { H0[indexForConjugateGradient][0], -H0[indexForConjugateGradient][1] };


            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex geometryH0expMinusOmega
                = { geometryH0conjugate[0] * expMinusOmega[0] - geometryH0conjugate[1] * expMinusOmega[1],
                    geometryH0conjugate[0] * expMinusOmega[1] + geometryH0conjugate[1] * expMinusOmega[0] };

            const fftwf_complex gradientH0expMinusOmega
                = { gradientH0conjugate[0] * expMinusOmega[0] - gradientH0conjugate[1] * expMinusOmega[1],
                    gradientH0conjugate[0] * expMinusOmega[1] + gradientH0conjugate[1] * expMinusOmega[0] };

            /* complex addition
               x = a + i*b
               y = c + i*d
               x+y = (a+c)+i(b+d)
            */


            // hTilde = H0expOmega + H0expMinusomega            
            const fftwf_complex geometryhTilde
                = { H0expOmega[0] + geometryH0expMinusOmega[0],
                    H0expOmega[1] + geometryH0expMinusOmega[1] };

            const fftwf_complex gradienthTilde
                = { H0expOmega[0] + gradientH0expMinusOmega[0],
                    H0expOmega[1] + gradientH0expMinusOmega[1] };


            //if ( indexForK >= geometryStartIndex && indexForK <= geometryEndIndex )
            if ( j > geometryXRange.x && j < geometryXRange.y
                 && i > geometryYRange.x && i < geometryYRange.y )
            {
                frequencySpectrum[geometryIndex][0] = geometryhTilde[0];
                frequencySpectrum[geometryIndex][1] = geometryhTilde[1];
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

            //const float derivativeXScale = (j == 0) ? 0.0f : 1.0f;
            //const float derivativeZScale = (i == 0) ? 0.0f : 1.0f;
            const float derivativeXScale   = (j == gradientPadding.x) ? 0.0f : 1.0f;
            const float derivativeZScale   = (i == gradientPadding.y) ? 0.0f : 1.0f;
            const float displacementXScale = (j == geometryPadding.x) ? 0.0f : 1.0f;
            const float displacementZScale = (i == geometryPadding.y) ? 0.0f : 1.0f;

            const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

            if ( j > gradientXRange.x && j < gradientXRange.y
                 && i > gradientYRange.x && i < gradientYRange.y )
            {
                const fftwf_complex gx
                    = {-kx * gradienthTilde[1] * derivativeXScale, kx * gradienthTilde[0] * derivativeXScale};

                const fftwf_complex gz
                    = {-ky * gradienthTilde[1] * derivativeZScale, ky * gradienthTilde[0] * derivativeZScale};

                // gx + i*gz
                gradient[gradientIndex][0] = gx[0] - gz[1];
                gradient[gradientIndex][1] = gx[1] + gz[0];

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

                displacementXdXdZ[gradientIndex][0] = dx_x[0] - dx_z[1];
                displacementXdXdZ[gradientIndex][1] = dx_x[1] + dx_z[0];

                displacementZdXdZ[gradientIndex][0] = dz_x[0] - dz_z[1];
                displacementZdXdZ[gradientIndex][1] = dz_x[1] + dz_z[0];
            }

            // -i * kx/|k| * H
            /*
            x  = 0 + i*(-kx/|k|)
            H  = c + i*d
            xH = (0*c - (-kx/|k| * d)) + i*(0*d + (-kx/|k| * c))
               = d*kx/|k| + i*(-c*kx/|k|)
            */

            
            if ( displacement != NULL
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
                displacement[geometryIndex][0] = dx[0] - dz[1];
                displacement[geometryIndex][1] = dx[1] + dz[0];
            }
        }
    }

    OdFrequencySpectrumFloat result
        = { .timestamp     = time,
            .geometryResolution = geometryResolution,
            .gradientResolution = gradientResolution,
            .size          = currentGeometry.sizes[0],
            .baseSpectrum  = NULL,
            .maxMeanSlopeVariance = 0.0f,
            .effectiveMeanSlopeVariance = 0.0f,
            .waveSpectrum  = frequencySpectrum,
            .gradientX     = NULL,
            .gradientZ     = NULL,
            .gradient      = gradient,
            .displacementX = NULL,
            .displacementZ = NULL,
            .displacement  = displacement,
            .displacementXdXdZ = displacementXdXdZ,
            .displacementZdXdZ = displacementZdXdZ };

    return result;
}

- (OdFrequencySpectrumFloat) generateTimeIndependentH
{
    return [ self generateHAtTime:1.0f ];
}

- (OdFrequencySpectrumFloat) generateHHCAtTime:(const float)time
{
    const IVector2 resolution = H0Resolution;
    const IVector2 geometryResolution = currentGeometry.geometryResolution;
    const IVector2 gradientResolution = currentGeometry.gradientResolution;
    const FVector2 size = (FVector2){currentGeometry.sizes[0].x, currentGeometry.sizes[0].y};

    const IVector2 geometryResolutionHC = { (geometryResolution.x / 2) + 1, geometryResolution.y };
    const IVector2 gradientResolutionHC = { (gradientResolution.x / 2) + 1, gradientResolution.y };

    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };
    const IVector2 geometryQuadrantResolution = { geometryResolution.x / 2, geometryResolution.y / 2 };
    const IVector2 gradientQuadrantResolution = { gradientResolution.x / 2, gradientResolution.y / 2 };

	fftwf_complex * frequencySpectrumHC
        = fftwf_alloc_complex(geometryResolutionHC.x * geometryResolutionHC.y);

	fftwf_complex * gradientXHC
        = fftwf_alloc_complex(gradientResolutionHC.x * gradientResolutionHC.y);

	fftwf_complex * gradientZHC
        = fftwf_alloc_complex(gradientResolutionHC.x * gradientResolutionHC.y);

    fftwf_complex * displacementXHC
        = fftwf_alloc_complex(geometryResolutionHC.x * geometryResolutionHC.y);

    fftwf_complex * displacementZHC
        = fftwf_alloc_complex(geometryResolutionHC.x * geometryResolutionHC.y);

    //memset(frequencySpectrumHC, 0, geometryResolutionHC.x * geometryResolutionHC.y * 2 * sizeof(float));
    //memset(gradientXHC, 0, geometryResolutionHC.x * geometryResolutionHC.y * 2 * sizeof(float));

    const IVector2 geometryPadding
        = { .x = (H0Resolution.x - geometryResolution.x) / 2, .y = (H0Resolution.y - geometryResolution.y) / 2 };

    const IVector2 gradientPadding
        = { .x = (H0Resolution.x - gradientResolution.x) / 2, .y = (H0Resolution.y - gradientResolution.y) / 2 };

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    // first generate quadrant 3
    // kx starts at 0 and increases
    // ky starts at 0 and decreases

    const float q3n = 0.0f;
    const float q3m = 0.0f;

    const IVector2 q3geometryXRange = { .x = -1, .y = quadrantResolution.x - geometryPadding.x };
    const IVector2 q3geometryYRange = { .x = -1, .y = quadrantResolution.y - geometryPadding.y };

    const IVector2 q3gradientXRange = { .x = -1, .y = quadrantResolution.x - gradientPadding.x };
    const IVector2 q3gradientYRange = { .x = -1, .y = quadrantResolution.y - gradientPadding.y };

    //[ timer update ];

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.x; j++ )
        {
            const int32_t iInH0 = i + quadrantResolution.y;
            const int32_t jInH0 = j + quadrantResolution.x;

            const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

            const int32_t jConjugateGeometry = MAX(0, (resolution.x - jInH0 - geometryPadding.x) % geometryResolution.x);
            const int32_t iConjugateGeometry = MAX(0, (resolution.y - iInH0 - geometryPadding.y) % geometryResolution.y);
            const int32_t jConjugateGradient = MAX(0, (resolution.x - jInH0 - gradientPadding.x) % gradientResolution.x);
            const int32_t iConjugateGradient = MAX(0, (resolution.y - iInH0 - gradientPadding.y) % gradientResolution.y);

            const int32_t indexForConjugateGeometry = jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
            const int32_t indexForConjugateGradient = jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

            const int32_t geometryIndexHC = j + (geometryResolutionHC.x * i);
            const int32_t gradientIndexHC = j + (gradientResolutionHC.x * i);

            const float di = i;
            const float dj = j;

            const float kx = (q3n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q3m - di) * MATH_2_MUL_PIf * dsizey;

            const float lengthK = sqrtf(kx * kx + ky * ky);
            const float omega = sqrtf(EARTH_ACCELERATIONf * lengthK);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

            const fftwf_complex geometryH0conjugate
                = { H0[indexForConjugateGeometry][0], -H0[indexForConjugateGeometry][1] };

            const fftwf_complex gradientH0conjugate
                = { H0[indexForConjugateGradient][0], -H0[indexForConjugateGradient][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex geometryH0expMinusOmega
                = { geometryH0conjugate[0] * expMinusOmega[0] - geometryH0conjugate[1] * expMinusOmega[1],
                    geometryH0conjugate[0] * expMinusOmega[1] + geometryH0conjugate[1] * expMinusOmega[0] };

            const fftwf_complex gradientH0expMinusOmega
                = { gradientH0conjugate[0] * expMinusOmega[0] - gradientH0conjugate[1] * expMinusOmega[1],
                    gradientH0conjugate[0] * expMinusOmega[1] + gradientH0conjugate[1] * expMinusOmega[0] };

            // hTilde = H0expOmega + H0expMinusomega            
            const fftwf_complex geometryhTilde
                = { H0expOmega[0] + geometryH0expMinusOmega[0],
                    H0expOmega[1] + geometryH0expMinusOmega[1] };

            const fftwf_complex gradienthTilde
                = { H0expOmega[0] + gradientH0expMinusOmega[0],
                    H0expOmega[1] + gradientH0expMinusOmega[1] };

            if ( j > q3geometryXRange.x && j < q3geometryXRange.y
                 && i > q3geometryYRange.x && i < q3geometryYRange.y )
            {
                // H = H0expOmega + H0expMinusomega
                frequencySpectrumHC[geometryIndexHC][0] = geometryhTilde[0];
                frequencySpectrumHC[geometryIndexHC][1] = geometryhTilde[1];
            }

            if ( gradientXHC != NULL && gradientZHC != NULL
                 && j > q3gradientXRange.x && j < q3gradientXRange.y
                 && i > q3gradientYRange.x && i < q3gradientYRange.y )
            {
                gradientXHC[gradientIndexHC][0] = -kx * gradienthTilde[1];
                gradientXHC[gradientIndexHC][1] =  kx * gradienthTilde[0];

                gradientZHC[gradientIndexHC][0] = -ky * gradienthTilde[1];
                gradientZHC[gradientIndexHC][1] =  ky * gradienthTilde[0];
            }

            if ( displacementXHC != NULL && displacementZHC != NULL
                 && j > q3geometryXRange.x && j < q3geometryXRange.y
                 && i > q3geometryYRange.x && i < q3geometryYRange.y )
            {
                const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

                displacementXHC[geometryIndexHC][0] = factor * kx * geometryhTilde[1];
                displacementXHC[geometryIndexHC][1] = factor * kx * geometryhTilde[0] * -1.0f;

                displacementZHC[geometryIndexHC][0] = factor * ky * geometryhTilde[1];
                displacementZHC[geometryIndexHC][1] = factor * ky * geometryhTilde[0] * -1.0f;
            }
        }
    }

    // second generate quadrant 2
    // kx starts at 0 and increases
    // ky starts at resolution.y/2 and decreases

    const float q2n = 0.0f;
    const float q2m = resolution.y / 2.0f;

    const IVector2 q2geometryXRange = { .x = -1, .y = quadrantResolution.x - geometryPadding.x };
    const IVector2 q2geometryYRange = { .x = geometryPadding.y - 1, .y = quadrantResolution.y  };

    const IVector2 q2gradientXRange = { .x = -1, .y = quadrantResolution.x - gradientPadding.x };
    const IVector2 q2gradientYRange = { .x = gradientPadding.y - 1, .y = quadrantResolution.y  };

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.x; j++ )
        {
            const int32_t iInH0 = i;
            const int32_t jInH0 = j + quadrantResolution.x;

            const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

            const int32_t jConjugateGeometry = MAX(0, (resolution.x - jInH0 - geometryPadding.x) % geometryResolution.x);
            const int32_t iConjugateGeometry = MAX(0, (resolution.y - iInH0 - geometryPadding.y) % geometryResolution.y);
            const int32_t jConjugateGradient = MAX(0, (resolution.x - jInH0 - gradientPadding.x) % gradientResolution.x);
            const int32_t iConjugateGradient = MAX(0, (resolution.y - iInH0 - gradientPadding.y) % gradientResolution.y);

            const int32_t indexForConjugateGeometry = jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
            const int32_t indexForConjugateGradient = jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

            const int32_t geometryIndexHC
                = j + (geometryResolutionHC.x * (i - geometryPadding.y + geometryQuadrantResolution.y));

            const int32_t gradientIndexHC
                = j + (gradientResolutionHC.x * (i - gradientPadding.y + gradientQuadrantResolution.y));

            const float di = i;
            const float dj = j;

            const float kx = (q2n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q2m - di) * MATH_2_MUL_PIf * dsizey;

            const float lengthK = sqrtf(kx * kx + ky * ky);
            const float omega = sqrtf(EARTH_ACCELERATIONf * lengthK);
            const float omegaT = fmodf(omega * time, MATH_2_MUL_PIf);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            const fftwf_complex expOmega = { cosf(omegaT), sinf(omegaT) };

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            const fftwf_complex expMinusOmega = { expOmega[0], -expOmega[1] };

            // H0[indexForK] * exp(i*omega*t)
            const fftwf_complex H0expOmega
                = { H0[indexForKInH0][0] * expOmega[0] - H0[indexForKInH0][1] * expOmega[1],
                    H0[indexForKInH0][0] * expOmega[1] + H0[indexForKInH0][1] * expOmega[0] };

                        const fftwf_complex geometryH0conjugate
                = { H0[indexForConjugateGeometry][0], -H0[indexForConjugateGeometry][1] };

            const fftwf_complex gradientH0conjugate
                = { H0[indexForConjugateGradient][0], -H0[indexForConjugateGradient][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex geometryH0expMinusOmega
                = { geometryH0conjugate[0] * expMinusOmega[0] - geometryH0conjugate[1] * expMinusOmega[1],
                    geometryH0conjugate[0] * expMinusOmega[1] + geometryH0conjugate[1] * expMinusOmega[0] };

            const fftwf_complex gradientH0expMinusOmega
                = { gradientH0conjugate[0] * expMinusOmega[0] - gradientH0conjugate[1] * expMinusOmega[1],
                    gradientH0conjugate[0] * expMinusOmega[1] + gradientH0conjugate[1] * expMinusOmega[0] };

            // hTilde = H0expOmega + H0expMinusomega            
            const fftwf_complex geometryhTilde
                = { H0expOmega[0] + geometryH0expMinusOmega[0],
                    H0expOmega[1] + geometryH0expMinusOmega[1] };

            const fftwf_complex gradienthTilde
                = { H0expOmega[0] + gradientH0expMinusOmega[0],
                    H0expOmega[1] + gradientH0expMinusOmega[1] };

            const float derivativeZScale = (i == 0) ? 0.0f : 1.0f;

            if ( j > q2geometryXRange.x && j < q2geometryXRange.y
                 && i > q2geometryYRange.x && i < q2geometryYRange.y )
            {
                // H = H0expOmega + H0expMinusomega
                frequencySpectrumHC[geometryIndexHC][0] = geometryhTilde[0];
                frequencySpectrumHC[geometryIndexHC][1] = geometryhTilde[1];
            }

            if ( gradientXHC != NULL && gradientZHC != NULL
                 && j > q2gradientXRange.x && j < q2gradientXRange.y
                 && i > q2gradientYRange.x && i < q2gradientYRange.y )
            {
                gradientXHC[gradientIndexHC][0] = -kx * gradienthTilde[1];
                gradientXHC[gradientIndexHC][1] =  kx * gradienthTilde[0];

                gradientZHC[gradientIndexHC][0] = -ky * gradienthTilde[1] * derivativeZScale;
                gradientZHC[gradientIndexHC][1] =  ky * gradienthTilde[0] * derivativeZScale;
            }

            if ( displacementXHC != NULL && displacementZHC != NULL
                 && j > q2geometryXRange.x && j < q2geometryXRange.y
                 && i > q2geometryYRange.x && i < q2geometryYRange.y )
            {
                const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

                displacementXHC[geometryIndexHC][0] = factor * kx * geometryhTilde[1];
                displacementXHC[geometryIndexHC][1] = factor * kx * geometryhTilde[0] * -1.0f;

                displacementZHC[geometryIndexHC][0] = derivativeZScale * factor * ky * geometryhTilde[1];
                displacementZHC[geometryIndexHC][1] = derivativeZScale * factor * ky * geometryhTilde[0] * -1.0f;
            }
        }
    }

    // third generate first column of quadrant 1
    // kx equals -resolution.x/2
    // ky starts at resolution.y/2 and decreases

    const float q1n = -(resolution.x / 2.0f);
    const float q1m = resolution.y / 2.0f;

    const IVector2 q1geometryYRange = { .x = geometryPadding.y - 1, .y = quadrantResolution.y  };
    const IVector2 q1gradientYRange = { .x = gradientPadding.y - 1, .y = quadrantResolution.y  };

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jGeometry = geometryPadding.x;
        const int32_t jGradient = gradientPadding.x;

        const int32_t jGeometryInH0 = jGeometry;
        const int32_t jGradientInH0 = jGradient;

        const int32_t iInH0 = i;

        const int32_t geometryIndexForKInH0 = jGeometryInH0 + (resolution.x * iInH0);
        const int32_t gradientIndexForKInH0 = jGradientInH0 + (resolution.x * iInH0);

        const int32_t jConjugateGeometry = MAX(0, (resolution.x - jGeometryInH0 - geometryPadding.x) % geometryResolution.x);
        const int32_t iConjugateGeometry = MAX(0, (resolution.y - iInH0         - geometryPadding.y) % geometryResolution.y);
        const int32_t jConjugateGradient = MAX(0, (resolution.x - jGradientInH0 - gradientPadding.x) % gradientResolution.x);
        const int32_t iConjugateGradient = MAX(0, (resolution.y - iInH0         - gradientPadding.y) % gradientResolution.y);

        const int32_t geometryIndexForKConjugateInH0 = jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
        const int32_t gradientIndexForKConjugateInH0 = jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

        const int32_t geometryIndexHC
            = geometryQuadrantResolution.x
              + (geometryResolutionHC.x * (i - geometryPadding.y + geometryQuadrantResolution.y));

        const int32_t gradientIndexHC
            = gradientQuadrantResolution.x
              + (gradientResolutionHC.x * (i - gradientPadding.y + gradientQuadrantResolution.y));

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float geometryDj = jGeometry;
        const float gradientDj = jGradient;

        const float geometrykx = (q1n + geometryDj) * MATH_2_MUL_PIf * dsizex;
        const float gradientkx = (q1n + gradientDj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q1m - di) * MATH_2_MUL_PIf * dsizey;

        const float geometryLengthK = sqrtf(geometrykx * geometrykx + ky * ky);
        const float gradientLengthK = sqrtf(gradientkx * gradientkx + ky * ky);
        const float geometryOmega = sqrtf(EARTH_ACCELERATIONf * geometryLengthK);
        const float gradientOmega = sqrtf(EARTH_ACCELERATIONf * gradientLengthK);
        const float geometryOmegaT = fmodf(geometryOmega * time, MATH_2_MUL_PIf);
        const float gradientOmegaT = fmodf(gradientOmega * time, MATH_2_MUL_PIf);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex geometryExpOmega = { cosf(geometryOmegaT), sinf(geometryOmegaT) };
        const fftwf_complex gradientExpOmega = { cosf(gradientOmegaT), sinf(gradientOmegaT) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftwf_complex geometryExpMinusOmega = { geometryExpOmega[0], -geometryExpOmega[1] };
        const fftwf_complex gradientExpMinusOmega = { gradientExpOmega[0], -gradientExpOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftwf_complex geometryH0expOmega
            = { H0[geometryIndexForKInH0][0] * geometryExpOmega[0] - H0[geometryIndexForKInH0][1] * geometryExpOmega[1],
                H0[geometryIndexForKInH0][0] * geometryExpOmega[1] + H0[geometryIndexForKInH0][1] * geometryExpOmega[0] };

        const fftwf_complex gradientH0expOmega
            = { H0[gradientIndexForKInH0][0] * gradientExpOmega[0] - H0[gradientIndexForKInH0][1] * gradientExpOmega[1],
                H0[gradientIndexForKInH0][0] * gradientExpOmega[1] + H0[gradientIndexForKInH0][1] * gradientExpOmega[0] };

        const fftwf_complex geometryH0conjugate
            = { H0[geometryIndexForKConjugateInH0][0], -H0[geometryIndexForKConjugateInH0][1] };

        const fftwf_complex gradientH0conjugate
            = { H0[gradientIndexForKConjugateInH0][0], -H0[gradientIndexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex geometryH0expMinusOmega
            = { geometryH0conjugate[0] * geometryExpMinusOmega[0] - geometryH0conjugate[1] * geometryExpMinusOmega[1],
                geometryH0conjugate[0] * geometryExpMinusOmega[1] + geometryH0conjugate[1] * geometryExpMinusOmega[0] };

        const fftwf_complex gradientH0expMinusOmega
            = { gradientH0conjugate[0] * gradientExpMinusOmega[0] - gradientH0conjugate[1] * gradientExpMinusOmega[1],
                gradientH0conjugate[0] * gradientExpMinusOmega[1] + gradientH0conjugate[1] * gradientExpMinusOmega[0] };

        // hTilde = H0expOmega + H0expMinusomega            
        const fftwf_complex geometryhTilde
            = { geometryH0expOmega[0] + geometryH0expMinusOmega[0],
                geometryH0expOmega[1] + geometryH0expMinusOmega[1] };

        const fftwf_complex gradienthTilde
            = { gradientH0expOmega[0] + gradientH0expMinusOmega[0],
                gradientH0expOmega[1] + gradientH0expMinusOmega[1] };

        const float derivativeXScale = 0.0f;
        const float derivativeZScale = (i == 0) ? 0.0f : 1.0f;

        if ( i > q1geometryYRange.x && i < q1geometryYRange.y )
        {
            frequencySpectrumHC[geometryIndexHC][0] = geometryhTilde[0];
            frequencySpectrumHC[geometryIndexHC][1] = geometryhTilde[1];
        }

        if ( gradientXHC != NULL && gradientZHC != NULL
             && i > q1gradientYRange.x && i < q1gradientYRange.y )
        {
            gradientXHC[gradientIndexHC][0] = -gradientkx * gradienthTilde[1] * derivativeXScale;
            gradientXHC[gradientIndexHC][1] =  gradientkx * gradienthTilde[0] * derivativeXScale;

            gradientZHC[gradientIndexHC][0] = -ky * gradienthTilde[1] * derivativeZScale;
            gradientZHC[gradientIndexHC][1] =  ky * gradienthTilde[0] * derivativeZScale;
        }

        if ( displacementXHC != NULL && displacementZHC != NULL
             && i > q1geometryYRange.x && i < q1geometryYRange.y )
        {
            const float factor = (geometryLengthK != 0.0f) ? 1.0f/geometryLengthK : 0.0f;

            displacementXHC[geometryIndexHC][0] = derivativeXScale * factor * geometrykx * geometryhTilde[1];
            displacementXHC[geometryIndexHC][1] = derivativeXScale * factor * geometrykx * geometryhTilde[0] * -1.0f;

            displacementZHC[geometryIndexHC][0] = derivativeZScale * factor * ky * geometryhTilde[1];
            displacementZHC[geometryIndexHC][1] = derivativeZScale * factor * ky * geometryhTilde[0] * -1.0f;
        }
    }

    // third generate first column of quadrant 4
    // kx equals -resolution.x/2
    // ky starts at 0.0 and decreases

    const float q4n = -(resolution.x / 2.0f);
    const float q4m = 0.0f;

    const IVector2 q4geometryYRange = { .x = -1, .y = quadrantResolution.y - geometryPadding.y };
    const IVector2 q4gradientYRange = { .x = -1, .y = quadrantResolution.y - gradientPadding.y };

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jGeometry = geometryPadding.x;
        const int32_t jGradient = gradientPadding.x;

        const int32_t jGeometryInH0 = jGeometry;
        const int32_t jGradientInH0 = jGradient;

        const int32_t iInH0 = i + quadrantResolution.y;

        const int32_t geometryIndexForKInH0 = jGeometryInH0 + (resolution.x * iInH0);
        const int32_t gradientIndexForKInH0 = jGradientInH0 + (resolution.x * iInH0);

        const int32_t jConjugateGeometry = MAX(0, (resolution.x - jGeometryInH0 - geometryPadding.x) % geometryResolution.x);
        const int32_t iConjugateGeometry = MAX(0, (resolution.y - iInH0         - geometryPadding.y) % geometryResolution.y);
        const int32_t jConjugateGradient = MAX(0, (resolution.x - jGradientInH0 - gradientPadding.x) % gradientResolution.x);
        const int32_t iConjugateGradient = MAX(0, (resolution.y - iInH0         - gradientPadding.y) % gradientResolution.y);

        const int32_t geometryIndexForKConjugateInH0 = jConjugateGeometry + geometryPadding.x + resolution.x * (iConjugateGeometry + geometryPadding.y);
        const int32_t gradientIndexForKConjugateInH0 = jConjugateGradient + gradientPadding.x + resolution.x * (iConjugateGradient + gradientPadding.y);

        const int32_t geometryIndexHC = geometryQuadrantResolution.x + (geometryResolutionHC.x * i);
        const int32_t gradientIndexHC = gradientQuadrantResolution.x + (gradientResolutionHC.x * i);

        const float di = i;
        const float geometryDj = jGeometry;
        const float gradientDj = jGradient;

        const float geometrykx = (q4n + geometryDj) * MATH_2_MUL_PIf * dsizex;
        const float gradientkx = (q4n + gradientDj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q4m - di) * MATH_2_MUL_PIf * dsizey;

        const float geometryLengthK = sqrtf(geometrykx * geometrykx + ky * ky);
        const float gradientLengthK = sqrtf(gradientkx * gradientkx + ky * ky);
        const float geometryOmega = sqrtf(EARTH_ACCELERATIONf * geometryLengthK);
        const float gradientOmega = sqrtf(EARTH_ACCELERATIONf * gradientLengthK);
        const float geometryOmegaT = fmodf(geometryOmega * time, MATH_2_MUL_PIf);
        const float gradientOmegaT = fmodf(gradientOmega * time, MATH_2_MUL_PIf);

        // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
        const fftwf_complex geometryExpOmega = { cosf(geometryOmegaT), sinf(geometryOmegaT) };
        const fftwf_complex gradientExpOmega = { cosf(gradientOmegaT), sinf(gradientOmegaT) };

        // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
        const fftwf_complex geometryExpMinusOmega = { geometryExpOmega[0], -geometryExpOmega[1] };
        const fftwf_complex gradientExpMinusOmega = { gradientExpOmega[0], -gradientExpOmega[1] };

        // H0[indexForK] * exp(i*omega*t)
        const fftwf_complex geometryH0expOmega
            = { H0[geometryIndexForKInH0][0] * geometryExpOmega[0] - H0[geometryIndexForKInH0][1] * geometryExpOmega[1],
                H0[geometryIndexForKInH0][0] * geometryExpOmega[1] + H0[geometryIndexForKInH0][1] * geometryExpOmega[0] };

        const fftwf_complex gradientH0expOmega
            = { H0[gradientIndexForKInH0][0] * gradientExpOmega[0] - H0[gradientIndexForKInH0][1] * gradientExpOmega[1],
                H0[gradientIndexForKInH0][0] * gradientExpOmega[1] + H0[gradientIndexForKInH0][1] * gradientExpOmega[0] };

        const fftwf_complex geometryH0conjugate
            = { H0[geometryIndexForKConjugateInH0][0], -H0[geometryIndexForKConjugateInH0][1] };

        const fftwf_complex gradientH0conjugate
            = { H0[gradientIndexForKConjugateInH0][0], -H0[gradientIndexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex geometryH0expMinusOmega
            = { geometryH0conjugate[0] * geometryExpMinusOmega[0] - geometryH0conjugate[1] * geometryExpMinusOmega[1],
                geometryH0conjugate[0] * geometryExpMinusOmega[1] + geometryH0conjugate[1] * geometryExpMinusOmega[0] };

        const fftwf_complex gradientH0expMinusOmega
            = { gradientH0conjugate[0] * gradientExpMinusOmega[0] - gradientH0conjugate[1] * gradientExpMinusOmega[1],
                gradientH0conjugate[0] * gradientExpMinusOmega[1] + gradientH0conjugate[1] * gradientExpMinusOmega[0] };

        // hTilde = H0expOmega + H0expMinusomega            
        const fftwf_complex geometryhTilde
            = { geometryH0expOmega[0] + geometryH0expMinusOmega[0],
                geometryH0expOmega[1] + geometryH0expMinusOmega[1] };

        const fftwf_complex gradienthTilde
            = { gradientH0expOmega[0] + gradientH0expMinusOmega[0],
                gradientH0expOmega[1] + gradientH0expMinusOmega[1] };

        const float derivativeXScale = 0.0f;

        if ( i > q4geometryYRange.x && i < q4geometryYRange.y )
        {
            frequencySpectrumHC[geometryIndexHC][0] = geometryhTilde[0];
            frequencySpectrumHC[geometryIndexHC][1] = geometryhTilde[1];
        }

        if ( gradientXHC != NULL && gradientZHC != NULL
             && i > q4gradientYRange.x && i < q4gradientYRange.y )
        {
            gradientXHC[gradientIndexHC][0] = -gradientkx * gradienthTilde[1] * derivativeXScale;
            gradientXHC[gradientIndexHC][1] =  gradientkx * gradienthTilde[0] * derivativeXScale;

            gradientZHC[gradientIndexHC][0] = -ky * gradienthTilde[1];
            gradientZHC[gradientIndexHC][1] =  ky * gradienthTilde[0];
        }

        if ( displacementXHC != NULL && displacementZHC != NULL
             && i > q4geometryYRange.x && i < q4geometryYRange.y )
        {
            const float factor = (geometryLengthK != 0.0f) ? 1.0f/geometryLengthK : 0.0f;

            displacementXHC[geometryIndexHC][0] = derivativeXScale * factor * geometrykx * geometryhTilde[1];
            displacementXHC[geometryIndexHC][1] = derivativeXScale * factor * geometrykx * geometryhTilde[0] * -1.0f;

            displacementZHC[geometryIndexHC][0] = factor * ky * geometryhTilde[1];
            displacementZHC[geometryIndexHC][1] = factor * ky * geometryhTilde[0] * -1.0f;
        }
    }

    OdFrequencySpectrumFloat result
        = { .timestamp     = time,
            .geometryResolution = geometryResolution,
            .gradientResolution = gradientResolution,
            .size          = currentGeometry.sizes[0],
            .baseSpectrum  = NULL,
            .maxMeanSlopeVariance = 0.0f,
            .effectiveMeanSlopeVariance = 0.0f,
            .waveSpectrum  = frequencySpectrumHC,
            .gradientX     = gradientXHC,
            .gradientZ     = gradientZHC,
            .gradient      = NULL,
            .displacementX = displacementXHC,
            .displacementZ = displacementZHC,
            .displacement  = NULL,
            .displacementXdXdZ = NULL,
            .displacementZdXdZ = NULL };

    return result;
}

- (OdFrequencySpectrumFloat) generateTimeIndependentHHC
{
    return [ self generateHHCAtTime:1.0f ];
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

    for ( int32_t i = startX; i < endX; i++ )
    {
        for ( int32_t j = startY; j < endY; j++ )
        {
            index = j + resolution.y * i;
            oppositeQuadrantIndex = (j + (halfResY * quadrants)) + resolution.y * (i + halfResX);

            tmp[0] = spectrum[index][0];
            tmp[1] = spectrum[index][1];

            spectrum[index][0] = spectrum[oppositeQuadrantIndex][0];
            spectrum[index][1] = spectrum[oppositeQuadrantIndex][1];

            spectrum[oppositeQuadrantIndex][0] = tmp[0];
            spectrum[oppositeQuadrantIndex][1] = tmp[1];
        }
    }
}

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumWithGeometry:(ODSpectrumGeometry)geometry
                            generator:(ODGeneratorSettings)generatorSettings
                               atTime:(const float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
{
    SAFE_FREE(currentGeometry.sizes);

    currentGeometry.numberOfLods = geometry.numberOfLods;
    currentGeometry.sizes = ALLOC_ARRAY(Vector2, geometry.numberOfLods);
    memcpy(currentGeometry.sizes, geometry.sizes, sizeof(Vector2) * geometry.numberOfLods);
    currentGeometry.geometryResolution = geometry.geometryResolution;
    currentGeometry.gradientResolution = geometry.gradientResolution;
    currentGeneratorSettings = generatorSettings;

    [ self generateH0:generateBaseGeometry ];

    OdFrequencySpectrumFloat result = [ self generateHAtTime:time ];

    [ self swapFrequencySpectrum:result.waveSpectrum
                      resolution:currentGeometry.geometryResolution
                       quadrants:ODQuadrant_1_3 ];

    [ self swapFrequencySpectrum:result.waveSpectrum
                      resolution:currentGeometry.geometryResolution
                       quadrants:ODQuadrant_2_4 ];

    if ( result.gradientX != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientX
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradientX
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.gradientZ != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradientZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.gradient != NULL )
    {
        [ self swapFrequencySpectrum:result.gradient
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradient
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementX != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementX
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementX
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementZ
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementZ
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacement != NULL )
    {
        [ self swapFrequencySpectrum:result.displacement
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacement
                          resolution:currentGeometry.geometryResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementXdXdZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementXdXdZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementXdXdZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementZdXdZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementZdXdZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementZdXdZ
                          resolution:currentGeometry.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    //NSLog(@"H0: %f H:%f Swap:%f", h0time, htime, swaptime);

    if ( baseSpectrum != NULL )
    {
        result.baseSpectrum = baseSpectrum;
        result.maxMeanSlopeVariance = maxMeanSlopeVariance;
        result.effectiveMeanSlopeVariance = effectiveMeanSlopeVariance;

        baseSpectrum = NULL;
        maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;
    }

    SAFE_FREE(lastGeometry.sizes);
    lastGeometry.numberOfLods = currentGeometry.numberOfLods;
    lastGeometry.sizes = ALLOC_ARRAY(Vector2, currentGeometry.numberOfLods);
    memcpy(lastGeometry.sizes, currentGeometry.sizes, sizeof(Vector2) * currentGeometry.numberOfLods);
    lastGeometry.geometryResolution = currentGeometry.geometryResolution;
    lastGeometry.gradientResolution = currentGeometry.gradientResolution;

    lastGeneratorSettings = currentGeneratorSettings;

    return result;
}

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumHCWithGeometry:(ODSpectrumGeometry)geometry
                              generator:(ODGeneratorSettings)generatorSettings
                                 atTime:(const float)time
                   generateBaseGeometry:(BOOL)generateBaseGeometry
{
    SAFE_FREE(currentGeometry.sizes);

    currentGeometry.numberOfLods = geometry.numberOfLods;
    currentGeometry.sizes = ALLOC_ARRAY(Vector2, geometry.numberOfLods);
    memcpy(currentGeometry.sizes, geometry.sizes, sizeof(Vector2) * geometry.numberOfLods);
    currentGeometry.geometryResolution = geometry.geometryResolution;
    currentGeometry.gradientResolution = geometry.gradientResolution;

    currentGeneratorSettings = generatorSettings;

    [ self generateH0:generateBaseGeometry ];
    OdFrequencySpectrumFloat result= [ self generateHHCAtTime:time ];

    if ( baseSpectrum != NULL )
    {
        result.baseSpectrum = baseSpectrum;
        result.maxMeanSlopeVariance = maxMeanSlopeVariance;
        result.effectiveMeanSlopeVariance = effectiveMeanSlopeVariance;

        baseSpectrum = NULL;
        maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;
    }

    SAFE_FREE(lastGeometry.sizes);
    lastGeometry.numberOfLods = currentGeometry.numberOfLods;
    lastGeometry.sizes = ALLOC_ARRAY(Vector2, currentGeometry.numberOfLods);
    memcpy(lastGeometry.sizes, currentGeometry.sizes, sizeof(Vector2) * currentGeometry.numberOfLods);
    lastGeometry.geometryResolution = currentGeometry.geometryResolution;
    lastGeometry.gradientResolution = currentGeometry.gradientResolution;

    lastGeneratorSettings = currentGeneratorSettings;

    return result;
}

@end

