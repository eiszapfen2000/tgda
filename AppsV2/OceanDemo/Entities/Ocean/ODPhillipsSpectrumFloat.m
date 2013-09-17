#import "Foundation/NSException.h"
#import "Core/Timer/NPTimer.h"
#import "ODConstants.h"
#import "ODPhillipsSpectrumFloat.h"

#define FFTW_FREE(_pointer)        do {void *_ptr=(void *)(_pointer); fftwf_free(_ptr); _pointer=NULL; } while (0)
#define FFTW_SAFE_FREE(_pointer)   { if ( (_pointer) != NULL ) FFTW_FREE((_pointer)); }

typedef enum ODQuadrants
{
    ODQuadrant_1_3 =  1,
    ODQuadrant_2_4 = -1
}
ODQuadrants;

static inline float omegaf_for_k(FVector2 const * const k)
{
    return sqrtf(EARTH_ACCELERATIONf * fv2_v_length(k));
}

static float amplitudef_cartesian(const FVector2 windDirectionNormalised,
                                  const FVector2 k, const float A,
                                  const float L, const float l)
{
    const float kSquareLength = k.x * k.x + k.y * k.y;

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    const float kLength = sqrtf(kSquareLength);
    const FVector2 kNormalised = { .x = k.x / kLength, .y = k.y / kLength };

    float amplitude = A;
/*
    Use exp because glibc on Ubuntu 10.04 does not contain a optimised
    version of expf yet, expf is way slower than exp
*/
    amplitude = amplitude * (float)exp(( -1.0 / (kSquareLength * L * L)) - (kSquareLength * l * l));
    amplitude = amplitude * ( 1.0f / (kSquareLength * kSquareLength) );

    const float kdotw
        = kNormalised.x * windDirectionNormalised.x + kNormalised.y * windDirectionNormalised.y;

    amplitude = amplitude * kdotw * kdotw * kdotw * kdotw;

    return amplitude;
}

static float amplitudef_polar(const FVector2 windDirectionNormalised,
                              const float k, const float phi, const float A,
                              const float L, const float l)
{
    // rotate (1,0) by phi

    const float x = cosf(phi);
    const float y = sinf(phi);
    const FVector2 kv = {.x = x * k, .y = y * k};

    return amplitudef_cartesian(windDirectionNormalised,
                                kv, A, L, l);
}

static NPTimer * timer = nil;


@implementation ODPhillipsSpectrumFloat

+ (void) initialize
{
	if ( [ ODPhillipsSpectrumFloat class ] == self )
    {
        if ( timer == nil )
        {
            timer = [[ NPTimer alloc ] initWithName:@"SpectrumTimer" ];
        }
    }
}

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum Float" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    H0 = NULL;
    randomNumbers = NULL;
    H0Resolution = iv2_zero();

    gaussianRNG = odgaussianrng_alloc_init();

    lastSettings.geometryResolution = iv2_max();
    lastSettings.gradientResolution = iv2_max();
    lastSettings.size = v2_max();
    lastSettings.windDirection = v2_max();
    lastSettings.windSpeed = DBL_MAX;
    lastSettings.dampening = DBL_MAX;

    currentSettings.geometryResolution = iv2_zero();
    currentSettings.gradientResolution = iv2_zero();
    currentSettings.size = v2_zero();
    currentSettings.windDirection = v2_zero();
    currentSettings.windSpeed = 0.0;
    currentSettings.dampening = 0.0;

    return self;
}

- (void) dealloc
{
    FFTW_SAFE_FREE(H0);
    SAFE_FREE(randomNumbers);
    odgaussianrng_free(gaussianRNG);

    [ super dealloc ];
}

- (void) generateH0:(BOOL)force
{
    if ( currentSettings.size.x == lastSettings.size.x
         && currentSettings.size.y == lastSettings.size.y
         && currentSettings.windDirection.x == lastSettings.windDirection.x
         && currentSettings.windDirection.y == lastSettings.windDirection.y
         && currentSettings.windSpeed == lastSettings.windSpeed
         && currentSettings.dampening == lastSettings.dampening
         && currentSettings.geometryResolution.x == lastSettings.geometryResolution.x
         && currentSettings.geometryResolution.y == lastSettings.geometryResolution.y
         && currentSettings.gradientResolution.x == lastSettings.gradientResolution.x
         && currentSettings.gradientResolution.y == lastSettings.gradientResolution.y
         && force == NO )
    {
        return;
    }

    BOOL generateRandomNumbers = force;

    if ( currentSettings.geometryResolution.x != lastSettings.geometryResolution.x
         || currentSettings.geometryResolution.y != lastSettings.geometryResolution.y
         || currentSettings.gradientResolution.x != lastSettings.gradientResolution.x
         || currentSettings.gradientResolution.y != lastSettings.gradientResolution.y )
    {
        IVector2 resolution;
        resolution.x = MAX(currentSettings.geometryResolution.x, currentSettings.gradientResolution.x);
        resolution.y = MAX(currentSettings.geometryResolution.y, currentSettings.gradientResolution.y);

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

    const IVector2 resolution = H0Resolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};
    const FVector2 windDirection = (FVector2){currentSettings.windDirection.x, currentSettings.windDirection.y};
    const FVector2 windDirectionNormalised = fv2_v_normalised(&windDirection);
    const float    windSpeed = currentSettings.windSpeed;
    const float    dampening = currentSettings.dampening;

    assert(dampening < 1.0f);

    const float A = PHILLIPS_CONSTANT * (1.0 / (size.x * size.y));
    const float L = (windSpeed * windSpeed) / EARTH_ACCELERATIONf;
    const float l = dampening * L;

    const float n = -(resolution.x / 2.0f);
    const float m =  (resolution.y / 2.0f);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    const float dkx = MATH_2_MUL_PIf * dsizex;
    const float dky = MATH_2_MUL_PIf * dsizey;

    if ( generateRandomNumbers == YES )
    {
        odgaussianrng_get_array(gaussianRNG, randomNumbers, 2 * resolution.x * resolution.y);
    }

    float varianceX = 0.0;
    float varianceY = 0.0;
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
            const float s = amplitudef_cartesian(windDirectionNormalised, k, A, L, l);
            const float a = sqrtf(s);

            varianceX += (kx * kx) * (dkx * dky) * s;
            varianceY += (ky * ky) * (dkx * dky) * s;
            varianceXY += (kx * kx + ky * ky) * (dkx * dky) * s;

            H0[j + resolution.x * i][0] = MATH_1_DIV_SQRT_2f * xi_r * a;
            H0[j + resolution.x * i][1] = MATH_1_DIV_SQRT_2f * xi_i * a;
        }
    }

    /*
    // eq. A6
    float mss = 0.0f;

    for ( float k = 0.001f; k < 1000.0f; k = k * 1.001f )
    {
        const float kSquare = k * k;
        const float dk = (k * 1.001f) - k;

        // eq A3
        float sk = 0.0;
        for ( float phi = -MATH_PI; phi <= MATH_PI; phi = phi + 0.1f )
        {
            sk += amplitudef_polar(windDirectionNormalised, k, phi, A, L, l) * k * 0.1f;
        }

        mss += kSquare * sk * dk;
    }

    NSLog(@"%f %f %f %f", varianceX, varianceY, varianceXY, varianceX + varianceY);
    NSLog(@"%f", mss);

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

- (OdFrequencySpectrumFloat) generateHAtTime:(const float)time
{
    const IVector2 resolution = H0Resolution;
    const IVector2 geometryResolution = currentSettings.geometryResolution;
    const IVector2 gradientResolution = currentSettings.gradientResolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

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
            .size          = currentSettings.size,
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
    const IVector2 resolution = currentSettings.gradientResolution;
    const FVector2 size = (FVector2){currentSettings.size.x, currentSettings.size.y};

    const IVector2 resolutionHC = { (resolution.x / 2) + 1, resolution.y };
    const IVector2 quadrantResolution = { resolution.x / 2, resolution.y / 2 };

	fftwf_complex * frequencySpectrumHC
        = fftwf_alloc_complex(resolutionHC.x * resolutionHC.y);

    const float dsizex = 1.0f / size.x;
    const float dsizey = 1.0f / size.y;

    // first generate quadrant 3
    // kx starts at 0 and increases
    // ky starts at 0 and decreases

    const float q3n = 0.0f;
    const float q3m = 0.0f;

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

            const int32_t indexHC = j + (resolutionHC.x * i);

            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

            const float di = i;
            const float dj = j;

            const float kx = (q3n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q3m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float omega = omegaf_for_k(&k);
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
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
        }
    }

    // second generate quadrant 2
    // kx starts at 0 and increases
    // ky starts at resolution.y/2 and decreases

    const float q2n = 0.0f;
    const float q2m = resolution.y / 2.0f;

    for ( int32_t i = 0; i < quadrantResolution.y; i++ )
    {
        for ( int32_t j = 0; j < quadrantResolution.x; j++ )
        {
            const int32_t iInH0 = i;
            const int32_t jInH0 = j + quadrantResolution.x;

            const int32_t indexForKInH0 = jInH0 + (resolution.x * iInH0);

            const int32_t indexForKConjugateInH0
                = ((resolution.x - jInH0) % resolution.x) + resolution.x * ((resolution.y - iInH0) % resolution.y);

            const int32_t indexHC = j + (resolutionHC.x * (i + quadrantResolution.y));

            //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

            const float di = i;
            const float dj = j;

            const float kx = (q2n + dj) * MATH_2_MUL_PIf * dsizex;
            const float ky = (q2m - di) * MATH_2_MUL_PIf * dsizey;

            const FVector2 k = {kx, ky};
            const float omega = omegaf_for_k(&k);
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
            frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
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

        const int32_t indexHC = quadrantResolution.x + (resolutionHC.x * (i + quadrantResolution.y));

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q1n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q1m - di) * MATH_2_MUL_PIf * dsizey;

        const FVector2 k = {kx, ky};
        const float omega = omegaf_for_k(&k);
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
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
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

        const int32_t indexHC = quadrantResolution.x + (resolutionHC.x * i);

        //printf("%d %d %d %d %d %d %d\n", j, i, jInH0, iInH0, indexForKInH0, indexForKConjugateInH0, indexHC);

        const float di = i;
        const float dj = j;

        const float kx = (q4n + dj) * MATH_2_MUL_PIf * dsizex;
        const float ky = (q4m - di) * MATH_2_MUL_PIf * dsizey;

        const FVector2 k = {kx, ky};
        const float omega = omegaf_for_k(&k);
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
        frequencySpectrumHC[indexHC][0] = H0expOmega[0] + H0expMinusOmega[0];
        frequencySpectrumHC[indexHC][1] = H0expOmega[1] + H0expMinusOmega[1];
    }

    OdFrequencySpectrumFloat result
        = { .timestamp = time,
            .geometryResolution = resolution,
            .gradientResolution = resolution,
            .size = currentSettings.size,
            .waveSpectrum = frequencySpectrumHC,
            .gradientX = NULL,
            .gradientZ = NULL,
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

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                                     atTime:(const float)time
                                       generateBaseGeometry:(BOOL)generateBaseGeometry
{
    currentSettings = settings;

    [ timer update];
    [ self generateH0:generateBaseGeometry ];
    [ timer update];

    const double h0time = [ timer frameTime ];

    OdFrequencySpectrumFloat result = [ self generateHAtTime:time ];
    [ timer update ];

    const double htime = [ timer frameTime ];

    [ self swapFrequencySpectrum:result.waveSpectrum
                      resolution:currentSettings.geometryResolution
                       quadrants:ODQuadrant_1_3 ];

    [ self swapFrequencySpectrum:result.waveSpectrum
                      resolution:currentSettings.geometryResolution
                       quadrants:ODQuadrant_2_4 ];

    if ( result.gradientX != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientX
                          resolution:currentSettings.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradientX
                          resolution:currentSettings.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.gradientZ != NULL )
    {
        [ self swapFrequencySpectrum:result.gradientZ
                          resolution:currentSettings.gradientResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.gradientZ
                          resolution:currentSettings.gradientResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementX != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementX
                          resolution:currentSettings.geometryResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementX
                          resolution:currentSettings.geometryResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    if ( result.displacementZ != NULL )
    {
        [ self swapFrequencySpectrum:result.displacementZ
                          resolution:currentSettings.geometryResolution
                           quadrants:ODQuadrant_1_3 ];

        [ self swapFrequencySpectrum:result.displacementZ
                          resolution:currentSettings.geometryResolution
                           quadrants:ODQuadrant_2_4 ];
    }

    [ timer update ];

    lastSettings = currentSettings;

    const double swaptime = [ timer frameTime ];

    //NSLog(@"H0: %f H:%f Swap:%f", h0time, htime, swaptime);

    return result;
}

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                                       atTime:(const float)time
                                         generateBaseGeometry:(BOOL)generateBaseGeometry
{
    currentSettings = settings;

    [ self generateH0:generateBaseGeometry ];
    OdFrequencySpectrumFloat result= [ self generateHHCAtTime:time ];
    lastSettings = currentSettings;

    return result;
}

@end

