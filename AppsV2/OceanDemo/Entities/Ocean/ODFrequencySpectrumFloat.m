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

    const IVector2 resolution = H0Resolution;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(resolution.x * resolution.y);

    const float U10   = settings.U10;
    const float Omega = settings.Omega;

    const FVector2 size = fv2_v_from_v2(&(currentGeometry.size));
    const float A = currentGeneratorSettings.spectrumScale / (size.x * size.y);

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    const float dkx = MATH_2_MUL_PIf * dsizex;
    const float dky = MATH_2_MUL_PIf * dsizey;

    float varianceX  = 0.0;
    float varianceY  = 0.0;
    float varianceXY = 0.0;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const float xi_r = (float)randomNumbers[2 * (j + resolution.x * i)    ];
            const float xi_i = (float)randomNumbers[2 * (j + resolution.x * i) + 1];

            const float di = i;
            const float dj = j;

            const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float s = MAX(0.0f, amplitudef_unified_cartesian(k, A, U10, Omega));
            const float a = sqrtf(s);

            varianceX  += (kx * kx) * (dkx * dky) * s;
            varianceY  += (ky * ky) * (dkx * dky) * s;
            varianceXY += (kx * kx + ky * ky) * (dkx * dky) * s;

            baseSpectrum[j + resolution.x * i] = s;
            H0[j + resolution.x * i][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
            H0[j + resolution.x * i][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
        }
    }

    float mss = 0.0f;

    for ( float k = 0.001f; k < 1000.0f; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        float sk = amplitudef_unified_cartesian_omnidirectional(k, A, U10, Omega);

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

    const IVector2 resolution = H0Resolution;

    FFTW_SAFE_FREE(baseSpectrum);
    baseSpectrum = fftwf_alloc_real(resolution.x * resolution.y);

    const FVector2 size = fv2_v_from_v2(&(currentGeometry.size));
    const FVector2 windDirection = fv2_v_from_v2(&(settings.windDirection));
    const FVector2 windDirectionNormalised = fv2_v_normalised(&windDirection);
    const float    windSpeed = settings.windSpeed;
    const float    dampening = settings.dampening;

    assert(dampening < 1.0f);

    const float A = currentGeneratorSettings.spectrumScale / (size.x * size.y);
    const float L = (windSpeed * windSpeed) / EARTH_ACCELERATIONf;
    const float l = dampening * L;

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    const float dkx = MATH_2_MUL_PIf * dsizex;
    const float dky = MATH_2_MUL_PIf * dsizey;

    float varianceX  = 0.0;
    float varianceY  = 0.0;
    float varianceXY = 0.0;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const float xi_r = (float)randomNumbers[2 * (j + resolution.x * i)    ];
            const float xi_i = (float)randomNumbers[2 * (j + resolution.x * i) + 1];
            //const float xi_r = (float)odgaussianrng_get_next(gaussianRNG);
            //const float xi_i = (float)odgaussianrng_get_next(gaussianRNG);

            const float di = i;
            const float dj = j;

            const float kx = (n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float s = amplitudef_phillips_cartesian(windDirectionNormalised, k, A, L, l);
            const float a = sqrtf(s);

            varianceX  += (kx * kx) * (dkx * dky) * s;
            varianceY  += (ky * ky) * (dkx * dky) * s;
            varianceXY += (kx * kx + ky * ky) * (dkx * dky) * s;

            baseSpectrum[j + resolution.x * i] = s;
            H0[j + resolution.x * i][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
            H0[j + resolution.x * i][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
        }
    }

    float mss = 0.0f;

    for ( float k = 0.001f; k < 1000.0f; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        float sk = amplitudef_phillips_cartesian_omnidirectional(k, A, L, l);

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

    if ( geometries_equal_resolution(&currentGeometry, &lastGeometry) == false)
    {
        IVector2 resolution;
        resolution.x = MAX(currentGeometry.geometryResolution.x, currentGeometry.gradientResolution.x);
        resolution.y = MAX(currentGeometry.geometryResolution.y, currentGeometry.gradientResolution.y);

        if ( resolution.x != H0Resolution.x || resolution.y != H0Resolution.y )
        {
            FFTW_SAFE_FREE(H0);
            SAFE_FREE(randomNumbers);
	        H0 = fftwf_alloc_complex(resolution.x * resolution.y);
	        randomNumbers = ALLOC_ARRAY(double, 2 * resolution.x * resolution.y);

            H0Resolution = resolution;
            generateRandomNumbers = YES;
        }
    }

    if ( generateRandomNumbers == YES )
    {
        odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * H0Resolution.x * H0Resolution.y);
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


@implementation ODFrequencySpectrumFloat

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

    gaussianRNG = odgaussianrng_alloc_init();

    maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;

    lastGeometry.geometryResolution = iv2_max();
    lastGeometry.gradientResolution = iv2_max();
    lastGeometry.size = v2_max();

    currentGeometry.geometryResolution = iv2_zero();
    currentGeometry.gradientResolution = iv2_zero();
    currentGeometry.size = v2_zero();

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
    const FVector2 size = (FVector2){currentGeometry.size.x, currentGeometry.size.y};

	fftwf_complex * frequencySpectrum
        = fftwf_alloc_complex(geometryResolution.x * geometryResolution.y);

	fftwf_complex * gradientX //= NULL;
        = fftwf_alloc_complex(gradientResolution.x * gradientResolution.y);

	fftwf_complex * gradientZ //= NULL;
        = fftwf_alloc_complex(gradientResolution.x * gradientResolution.y);

    fftwf_complex * displacementX //= NULL;
        = fftwf_alloc_complex(geometryResolution.x * geometryResolution.y);

    fftwf_complex * displacementZ //= NULL;
        = fftwf_alloc_complex(geometryResolution.x * geometryResolution.y);

    const IVector2 geometryPadding
        = { .x = (H0Resolution.x - geometryResolution.x) / 2, .y = (H0Resolution.y - geometryResolution.y) / 2 };

    const IVector2 gradientPadding
        = { .x = (H0Resolution.x - gradientResolution.x) / 2, .y = (H0Resolution.y - gradientResolution.y) / 2 };

    const IVector2 geometryXRange = {.x = geometryPadding.x - 1, .y = resolution.x - geometryPadding.x };
    const IVector2 geometryYRange = {.x = geometryPadding.y - 1, .y = resolution.y - geometryPadding.y };

    const IVector2 gradientXRange = {.x = gradientPadding.x - 1, .y = resolution.x - gradientPadding.x };
    const IVector2 gradientYRange = {.x = gradientPadding.y - 1, .y = resolution.y - gradientPadding.y };


    //NSLog(@"H: %d %d %d %d", geometryStartIndex, geometryEndIndex, gradientStartIndex, gradientEndIndex);

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t indexForK = j + resolution.x * i;
            const int32_t indexForConjugate = ((resolution.x - j) % resolution.x) + resolution.x * ((resolution.y - i) % resolution.y);

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

            const fftwf_complex H0conjugate
                = { H0[indexForConjugate][0], -H0[indexForConjugate][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            /* complex addition
               x = a + i*b
               y = c + i*d
               x+y = (a+c)+i(b+d)
            */


            // hTilde = H0expOmega + H0expMinusomega            
            const fftwf_complex hTilde
                = { H0expOmega[0] + H0expMinusOmega[0],
                    H0expOmega[1] + H0expMinusOmega[1] } ;


            //if ( indexForK >= geometryStartIndex && indexForK <= geometryEndIndex )
            if ( j > geometryXRange.x && j < geometryXRange.y
                 && i > geometryYRange.x && i < geometryYRange.y )
            {
                //printf("%d %d\n", geometryIndex, gradientIndex);
                frequencySpectrum[geometryIndex][0] = hTilde[0];
                frequencySpectrum[geometryIndex][1] = hTilde[1];
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

            if ( gradientX != NULL && gradientZ != NULL
                 && j > gradientXRange.x && j < gradientXRange.y
                 && i > gradientYRange.x && i < gradientYRange.y )
            {

                gradientX[gradientIndex][0] = -kx * hTilde[1];
                gradientX[gradientIndex][1] =  kx * hTilde[0];

                gradientZ[gradientIndex][0] = -ky * hTilde[1];
                gradientZ[gradientIndex][1] =  ky * hTilde[0];
            }

            // -i * kx/|k| * H
            /*
            x  = 0 + i*(-kx/|k|)
            H  = c + i*d
            xH = (0*c - (-kx/|k| * d)) + i*(0*d + (-kx/|k| * c))
               = d*kx/|k| + i*(-c*kx/|k|)
            */

            
            if ( displacementX != NULL && displacementZ != NULL
                 && j > geometryXRange.x && j < geometryXRange.y
                 && i > geometryYRange.x && i < geometryYRange.y )
            {
                const float factor = (lengthK != 0.0f) ? 1.0f/lengthK : 0.0f;

                displacementX[geometryIndex][0] = factor * kx * hTilde[1];
                displacementX[geometryIndex][1] = factor * kx * hTilde[0] * -1.0f;

                displacementZ[geometryIndex][0] = factor * ky * hTilde[1];
                displacementZ[geometryIndex][1] = factor * ky * hTilde[0] * -1.0f;
            }
        }
    }

    OdFrequencySpectrumFloat result
        = { .timestamp     = time,
            .geometryResolution = geometryResolution,
            .gradientResolution = gradientResolution,
            .size          = currentGeometry.size,
            .baseSpectrum  = NULL,
            .maxMeanSlopeVariance = 0.0f,
            .effectiveMeanSlopeVariance = 0.0f,
            .waveSpectrum  = frequencySpectrum,
            .gradientX     = gradientX,
            .gradientZ     = gradientZ,
            .displacementX = displacementX,
            .displacementZ = displacementZ };

    //NSLog(@"H end");

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
    const FVector2 size = (FVector2){currentGeometry.size.x, currentGeometry.size.y};

    const IVector2 geometryResolutionHC = { (geometryResolution.x / 2) + 1, geometryResolution.y };
    const IVector2 gradientResolutionHC = { (gradientResolution.x / 2) + 1, gradientResolution.y };

    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };

	fftwf_complex * frequencySpectrumHC
        = fftwf_alloc_complex(geometryResolutionHC.x * geometryResolutionHC.y);

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

            const int32_t indexForKConjugateInH0
                = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

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

            const fftwf_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };


            if ( j > q3geometryXRange.x && j < q3geometryXRange.y
                 && i > q3geometryYRange.x && i < q3geometryYRange.y )
            {
            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, geometryIndexHC);
                // H = H0expOmega + H0expMinusomega
                frequencySpectrumHC[geometryIndexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
                frequencySpectrumHC[geometryIndexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
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

            const int32_t indexForKConjugateInH0
                = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

            const int32_t geometryIndexHC = j + (geometryResolutionHC.x * (i + quadrantResolution.y));
            const int32_t gradientIndexHC = j + (gradientResolutionHC.x * (i + quadrantResolution.y));

            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

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

            const fftwf_complex H0conjugate
                = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

            // H0[indexForConjugate] * exp(-i*omega*t)
            const fftwf_complex H0expMinusOmega
                = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                    H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

            if ( j > q2geometryXRange.x && j < q2geometryXRange.y
                 && i > q2geometryYRange.x && i < q2geometryYRange.y )
            {
                // H = H0expOmega + H0expMinusomega
                frequencySpectrumHC[geometryIndexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
                frequencySpectrumHC[geometryIndexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
            }
        }
    }

    // third generate first column of quadrant 1
    // kx equals -resolution.x/2
    // ky starts at resolution.y/2 and decreases

    const float q1n = -(resolution.x / 2.0f);
    const float q1m = resolution.y / 2.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jInH0 = 0;
        const int32_t iInH0 = i;
        const int32_t j = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

        const int32_t geometryIndexHC = quadrantResolution.x + (geometryResolutionHC.x * (i + quadrantResolution.y));

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q1n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q1m - di) * MATH_2_MUL_PIf * dsizey;

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

        const fftwf_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[geometryIndexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[geometryIndexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    // third generate first column of quadrant 4
    // kx equals -resolution.x/2
    // ky starts at 0.0 and decreases

    const float q4n = -(resolution.x / 2.0f);
    const float q4m = 0.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        const int32_t jInH0 = 0;
        const int32_t iInH0 = i + quadrantResolution.y;
        const int32_t j = 0;

        const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

        const int32_t indexForKConjugateInH0
            = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

        const int32_t geometryIndexHC = quadrantResolution.x + (geometryResolutionHC.x * i);

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q4n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q4m - di) * MATH_2_MUL_PIf * dsizey;

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

        const fftwf_complex H0conjugate
            = { H0[indexForKConjugateInH0][0], -H0[indexForKConjugateInH0][1] };

        // H0[indexForConjugate] * exp(-i*omega*t)
        const fftwf_complex H0expMinusOmega
            = { H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1],
                H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0] };

        // H = H0expOmega + H0expMinusomega
        frequencySpectrumHC[geometryIndexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[geometryIndexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    OdFrequencySpectrumFloat result
        = { .timestamp     = time,
            .geometryResolution = geometryResolution,
            .gradientResolution = gradientResolution,
            .size          = currentGeometry.size,
            .baseSpectrum  = NULL,
            .maxMeanSlopeVariance = 0.0f,
            .effectiveMeanSlopeVariance = 0.0f,
            .waveSpectrum  = frequencySpectrumHC,
            .gradientX     = NULL,
            .gradientZ     = NULL,
            .displacementX = NULL,
            .displacementZ = NULL };

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
    currentGeometry = geometry;
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

    //NSLog(@"H0: %f H:%f Swap:%f", h0time, htime, swaptime);

    if ( baseSpectrum != NULL )
    {
        result.baseSpectrum = baseSpectrum;
        result.maxMeanSlopeVariance = maxMeanSlopeVariance;
        result.effectiveMeanSlopeVariance = effectiveMeanSlopeVariance;

        baseSpectrum = NULL;
        maxMeanSlopeVariance = effectiveMeanSlopeVariance = 0.0f;
    }

    lastGeometry = currentGeometry;
    lastGeneratorSettings = currentGeneratorSettings;

    return result;
}

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumHCWithGeometry:(ODSpectrumGeometry)geometry
                              generator:(ODGeneratorSettings)generatorSettings
                                 atTime:(const float)time
                   generateBaseGeometry:(BOOL)generateBaseGeometry
{
    currentGeometry = geometry;
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

    lastGeometry = currentGeometry;
    lastGeneratorSettings = currentGeneratorSettings;

    return result;
}

@end

