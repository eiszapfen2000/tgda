#import "TOFrequencySpectrumGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"

@implementation TOFrequencySpectrumGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOFrequencySpectrumGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ self resetFrequencySpectrum ];

    [ super dealloc ];
}

- (void) reset
{
    resX = resY = -1;
    width = length = -1;
    numberOfThreads = -1;

    if ( gaussianRNG != nil )
    {
        [ gaussianRNG release ];
        gaussianRNG = nil;
    }

    [ self resetFrequencySpectrum ];

    resOK = NO;
    sizeOK = NO;
    rngOK = NO;
    threadsOK = NO;
}

- (BOOL) ready
{
    return ( resOK && sizeOK && rngOK && threadsOK );
}

- (void) checkResolutionForReadiness
{
    if ( resX > 0 && resY > 0 )
    {
        resOK = YES;
    }
}

- (void) checkSizeForReadiness
{
    if ( length > 0 && width > 0 )
    {
        sizeOK = YES;
    }
}

- (void) checkGaussianRNGForReadiness
{
    if ( gaussianRNG != nil )
    {
        if ( [ gaussianRNG ready ] == YES )
        {
            rngOK = YES;
        }
    }
}

- (void) checkThreadsForReadiness
{
    if ( numberOfThreads > 0 )
    {
        threadsOK = YES;
    }
}

- (void) checkForReadiness
{
    [ self checkSizeForReadiness ];
    [ self checkResolutionForReadiness ];
    [ self checkGaussianRNGForReadiness ];
    [ self checkThreadsForReadiness ];
}

- (Int) resX
{
    return resX;
}

- (void) setResX:(Int)newResX
{
    resX = newResX;

    [ self checkResolutionForReadiness ];
}

- (Int) resY
{
    return resY;
}

- (void) setResY:(Int)newResY
{
    resY = newResY;

    [ self checkResolutionForReadiness ];
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;

    [ self checkSizeForReadiness ];
}

- (void) setLength:(Int)newLength
{
    length = newLength;

    [ self checkSizeForReadiness ];
}

- (void) setNumberOfThreads:(Int)newNumberOfThreads
{
    numberOfThreads = newNumberOfThreads;

    [ self checkThreadsForReadiness ];
}

- (void) setGaussianRNG:(NPGaussianRandomNumberGenerator *)newGaussianRNG
{
    if ( gaussianRNG != newGaussianRNG )
    {
        [ gaussianRNG release ];
        gaussianRNG = [ newGaussianRNG retain ];
    }

    [ self checkGaussianRNGForReadiness ];
}

- (void) resetFrequencySpectrum
{
    if ( frequencySpectrum != NULL )
    {
        fftw_free(frequencySpectrum);
        frequencySpectrum = NULL;
    }
}

- (fftw_complex *) frequencySpectrum
{
    return frequencySpectrum;
}

@end

@implementation TOPhillipsFrequencySpectrumGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOPhillipsFrequencySpectrumGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    H0 = NULL;

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ self resetH0 ];

    [ super dealloc ];
}

- (void) resetH0
{
    if ( H0 != NULL )
    {
        fftw_free(H0);
        H0 = NULL;
    }
}

- (void) reset
{
    V_X(windDirection) = V_Y(windDirection) = 0.0;
    windOK = NO;

    alpha = PHILLIPS_CONSTANT;

    [ self resetH0 ];

    [ super reset ];
}

- (BOOL) ready
{
    return ( [ super ready ] && windOK );
}

- (void) checkWindDirectionForReadiness
{
    if ( V_X(windDirection) != 0.0 && V_Y(windDirection) != 0.0 )
    {
        windOK = YES;
    }
}

- (void) checkForReadiness
{
    [ super checkForReadiness ];

    [ self checkWindDirectionForReadiness ];
}

- (void) setWindDirection:(Vector2 *)newWindDirection
{
    windDirection = *newWindDirection;

    [ self checkWindDirectionForReadiness ];
}

// dispersion relation
- (Double) kToOmega:(Vector2 *)k
{
    return sqrt(EARTH_ACCELERATION * v2_v_length(k));
}

- (Double) indexToKx:(Int)index
{
    Double n = -(resX / 2.0);
    n = n + (Double)index;

    return (MATH_2_MUL_PI * n) / width;
}

- (Double) indexToKy:(Int)index
{
    Double m = (resY / 2.0);
    m = m - (Double)index;

    return (MATH_2_MUL_PI * m) / length;
}

- (Double) getAmplitudeAt:(Vector2 *)k
{
    Double kSquareLength = v2_v_square_length(k);

    if ( kSquareLength == 0.0 )
    {
        return 0.0;
    }

    Double windDirectionSquareLength = v2_v_square_length(&windDirection);

    Vector2 windDirectionNormalised;
    v2_v_normalise_v(&windDirection, &windDirectionNormalised);

    Vector2 kNormalised;
    v2_v_normalise_v(k, &kNormalised);

    Double L = windDirectionSquareLength / EARTH_ACCELERATION;

    Double amplitude = PHILLIPS_CONSTANT;
    amplitude = amplitude * ( 1.0 / (kSquareLength * kSquareLength) );
    amplitude = amplitude * exp( -1.0 / (kSquareLength * L * L) );

    Double kdotw = v2_vv_dot_product(&kNormalised, &windDirectionNormalised);
    NSLog(@"knorm:%f %f wind:%f %f dot:%f",kNormalised.x,kNormalised.y,windDirectionNormalised.x,windDirectionNormalised.y,kdotw);

    amplitude = amplitude * pow(kdotw, 2.0);

    return amplitude;
}

- (void) generateH0
{
    Double xi_r, xi_i, a;
    Vector2 k;

	if ( !H0 )
	{
		H0 = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    for ( Int i = 0; i < resX; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
			xi_r = [ gaussianRNG nextGaussianFPRandomNumber ];
			xi_i = [ gaussianRNG nextGaussianFPRandomNumber ];

//            NSLog(@"rn: %f %f",xi_r,xi_i);

            k.x = [ self indexToKx:i ];
            k.y = [ self indexToKy:j ];

            NSLog(@"k: %f %f",k.x,k.y);

            a = sqrt([ self getAmplitudeAt:&k ]);

//            NSLog(@"a: %f",a);

			H0[j + resY * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			H0[j + resY * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;

            NSLog(@"H0: %f %f", H0[j + resY * i][0],H0[j + resY * i][1]);
        }
    }
}

/*- (void) generateH
{
    Vector2 k;
    Double omega;
    fftw_complex expOmega, expMinusOmega, H0expOmega, H0expMinusOmega;
    Int indexForK, indexForMinusK;
    Int ni, nj;

	if ( !frequencySpectrum )
	{
		frequencySpectrum = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    for ( Int i = 0; i < resX / 2; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
            indexForK = j + resY * i;

            ni = (resX - 1) - i;
            nj = (resY - 1) - j;
            indexForMinusK = ni * resY + nj;

            k.x = [ self indexToKx:i ];
            k.y = [ self indexToKy:j ];
            //NSLog(@"k: %f %f",k.x,k.y);

            omega = [ self kToOmega:&k ];
            //NSLog(@"omega: %f",omega);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            expOmega[0] = cos(omega);
            expOmega[1] = sin(omega);

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            expMinusOmega[0] = cos(omega);
            expMinusOmega[1] = -sin(omega);


            // H0[indexForK] * exp(i*omega*t)
            H0expOmega[0] = H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1];
            H0expOmega[1] = H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0];

            // H0[indexForMinusK] * exp(-i*omega*t)
            H0expMinusOmega[0] = H0[indexForMinusK][0] * expMinusOmega[0] - H0[indexForMinusK][1] * expMinusOmega[1];
            H0expMinusOmega[1] = H0[indexForMinusK][0] * expMinusOmega[1] + H0[indexForMinusK][1] * expMinusOmega[0];


            // H = H0expOmega + H0expMinusomega
            frequencySpectrum[indexForK][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrum[indexForK][1] = H0expOmega[1] + H0expMinusOmega[1];

            //NSLog(@"H: %f %f",H[indexForK][0],H[indexForK][1]);

            // H(-k) = conjugate of H(k)
            frequencySpectrum[indexForMinusK][0] =  frequencySpectrum[indexForK][0];
            frequencySpectrum[indexForMinusK][1] = -frequencySpectrum[indexForK][1];
            //NSLog(@"Hc: %f %f",H[indexForMinusK][0],H[indexForMinusK][1]);
        }
    }    
}*/

- (void) generateH
{
    Vector2 k;
    Double omega;
    fftw_complex expOmega, expMinusOmega, H0expOmega, H0expMinusOmega, H0conjugate;
    Int indexForK, indexForConjugate;

	if ( !frequencySpectrum )
	{
		frequencySpectrum = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    for ( Int i = 0; i < resX; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
            indexForK = j + resY * i;
            indexForConjugate = ((resY - j) % resY) + resY * ((resX - i) % resX);
            NSLog(@"indexfc: %d",indexForConjugate);

            k.x = [ self indexToKx:i ];
            k.y = [ self indexToKy:j ];
            //NSLog(@"k: %f %f",k.x,k.y);

            omega = [ self kToOmega:&k ];
            //NSLog(@"omega: %f",omega);

            // exp(i*omega*t) = (cos(omega*t) + i*sin(omega*t))
            expOmega[0] = cos(omega);
            expOmega[1] = sin(omega);

            // exp(-i*omega*t) = (cos(omega*t) - i*sin(omega*t))
            expMinusOmega[0] = cos(omega);
            expMinusOmega[1] = -sin(omega);

            /* complex multiplication
               x = a + i*b
               y = c + i*d
               xy = (ac-bd) + i(ad+bc)
            */

            // H0[indexForK] * exp(i*omega*t)
            H0expOmega[0] = H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1];
            H0expOmega[1] = H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0];


            H0conjugate[0] = H0[indexForConjugate][0];
            H0conjugate[1] = -H0[indexForConjugate][1];

            // H0[indexForConjugate] * exp(-i*omega*t)
            
            H0expMinusOmega[0] = H0conjugate[0] * expMinusOmega[0] - H0conjugate[1] * expMinusOmega[1];
            H0expMinusOmega[1] = H0conjugate[0] * expMinusOmega[1] + H0conjugate[1] * expMinusOmega[0];

            /* complex addition
               x = a + i*b
               y = c + i*d
               x+y = (a+c)+i(b+d)
            */

            // H = H0expOmega + H0expMinusomega
            frequencySpectrum[indexForK][0] = H0expOmega[0] + H0expMinusOmega[0];
            frequencySpectrum[indexForK][1] = H0expOmega[1] + H0expMinusOmega[1];

            //NSLog(@"H: %f %f",H[indexForK][0],H[indexForK][1]);

            // H(-k) = conjugate of H(k)

            //frequencySpectrum[indexForConjugate][0] =  frequencySpectrum[indexForK][0];
            //frequencySpectrum[indexForConjugate][1] = -frequencySpectrum[indexForK][1];
            //NSLog(@"Hc: %f %f",H[indexForMinusK][0],H[indexForMinusK][1]);
        }
    }    
}

/*
Frequeny Spectrum Quadrant Layout

---------
| 1 | 2 |
---------
| 4 | 3 |
---------

*/


#define QUADRANT_1_AND_3     1
#define QUADRANT_2_AND_4    -1

- (void) swapFrequencySpectrumQuadrants:(NPState)quadrants
{
    fftw_complex tmp;
    Int index, oppositeQuadrantIndex;

    Int startX = 0;
    Int endX = resX / 2;
    Int startY, endY;

    switch ( quadrants )
    {
        case QUADRANT_1_AND_3:
        {
            startY = 0;
            endY = resY/2;
            break;
        }
        case QUADRANT_2_AND_4:
        {
            startY = resY/2;
            endY = resY;
            break;
        }
    }

    for ( Int i = startX; i < endX; i++ )
    {
        for ( Int j = startY; j < endY; j++ )
        {
            index = j + resY * i;
            oppositeQuadrantIndex = (j + ((resY/2) * quadrants)) + resY * (i + resX/2);

            tmp[0] = frequencySpectrum[index][0];
            tmp[1] = frequencySpectrum[index][1];

            frequencySpectrum[index][0] = frequencySpectrum[oppositeQuadrantIndex][0];
            frequencySpectrum[index][1] = frequencySpectrum[oppositeQuadrantIndex][1];

            frequencySpectrum[oppositeQuadrantIndex][0] = tmp[0];
            frequencySpectrum[oppositeQuadrantIndex][1] = tmp[1];
        }
    }
}

- (void) printFrequencySpectrumAtPath:(NSString *)path
{
    NSMutableString * frequencyString = [[NSMutableString alloc] init];
    for ( Int i = 0; i < resX; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
            NSString * tmp = [ NSString stringWithFormat:@"%f %f ",frequencySpectrum[i+j*resY][0],frequencySpectrum[i+j*resY][1] ];
            [ frequencyString appendString:tmp ];
        }
        [ frequencyString appendFormat:@"\n" ];
    }
    [ frequencyString writeToFile:path atomically:YES ];
    [ frequencyString release ];
}

- (void) generateFrequencySpectrum
{
    if ( [ self ready ] == YES )
    {
        [ self generateH0 ];
        [ self generateH ];

        [ self printFrequencySpectrumAtPath:@"Frequency.txt" ];

        [ self swapFrequencySpectrumQuadrants:QUADRANT_1_AND_3 ];
        [ self swapFrequencySpectrumQuadrants:QUADRANT_2_AND_4 ];

        [ self printFrequencySpectrumAtPath:@"FrequencyShifted.txt" ];

    }
}

@end

@implementation TOSWOPFrequencySpectrumGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOSWOPFrequencySpectrumGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) reset
{
    U10 = -1.0;
    L = X = -1.0;
    LXOK = NO;
    U10OK = NO;

    [ super reset ];
}

- (BOOL) ready
{
    return [ super ready ] && LXOK && U10OK;
}

- (void) checkU10ForReadiness
{
    if ( U10 != 0.0 )
    {
        U10OK = YES;
    }
}

- (void) checkLXForReadiness
{
    if ( L != 0.0 && X != 0.0 )
    {
        LXOK = YES;
    }
}

- (void) setU10:(Double)newU10
{
    U10 = newU10;

    [ self checkU10ForReadiness ];
}

- (void) setWindDirection:(Vector2 *)newWindDirection
{
    U10 = v2_v_length(newWindDirection);

    [ self checkU10ForReadiness ];
}

- (void) setL:(Double)newL
{
    L = newL;

    [ self checkLXForReadiness ];
}

- (void) setX:(Double)newX
{
    X = newX;

    [ self checkLXForReadiness ];
}

- (Double) getFAtSigma:(Double)sigma andPhi:(Double)phi
{
    Double E = exp(-0.5 * pow((sigma*U10) / EARTH_ACCELERATION, 4.0));
    Double f = 1.0 + (0.5 + 0.82 * E) * cos(2 * sigma) + 0.32 * E * cos(4 * sigma);
    Double tmp = exp(-2.0 * pow(EARTH_ACCELERATION / (sigma * U10), -2.0));

    return SWOP_CONSTANT * pow(sigma, -6.0) * tmp * f;
}

- (Double) getAmplitudeAt:(Vector2 *)k
{
    Double kLength = v2_v_length(k);

    if ( kLength == 0.0 )
    {
        return 0.0;
    }

    Double sigma = sqrt(EARTH_ACCELERATION * kLength);
    Double phi = atan2(V_Y(*k), V_X(*k));

    Double tmp = (EARTH_ACCELERATION * EARTH_ACCELERATION) / (2 * pow(sigma, 3.0));

    return tmp * [ self getFAtSigma:sigma andPhi:phi ];
}

- (void) generateAmplitudes
{
	if ( !frequencySpectrum )
	{
        NSLog(@"alloc");
		frequencySpectrum = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    Int index = 0;

    Double u, v;
    Double ui, vj;
    Double phase;
    Vector2 k;
    Double xi_r, xi_i;
    Double amplitude;

    // deltau and deltav are the same
    Double deltau = MATH_2_MUL_PI / ((2.0 * L + 1.0) * (X / L));

    for ( Int i = 0; i < resX / 2; i++ )
    {
        for ( Int j = 0; j < resY; j++ )
        {
            index = j + resY * i;

            u = (i - L);
            v = (j - L);

            ui = u * (u * (L / X));
            vj = v * (v * (L / X));

            phase = MATH_2_MUL_PI * (ui / (2.0 * L + 1.0)) * (vj / (2.0 * L + 1.0));

            V_X(k) = u * deltau;
            V_Y(k) = v * deltau;

			xi_r = [ gaussianRNG nextGaussianFPRandomNumber ];
			xi_i = [ gaussianRNG nextGaussianFPRandomNumber ];

            amplitude = [self getAmplitudeAt:&k ] * deltau * deltau;

            frequencySpectrum[index][0] = xi_r * amplitude * cos(phase);
            frequencySpectrum[index][1] = xi_i * amplitude * sin(phase);
        }
    }
}

- (void) generateFrequencySpectrum
{
    L = (Double)resX / 2.0;
    X = (Double)length / 2.0;

    [ self checkLXForReadiness ];

    if ( [ self ready ] == YES )
    {
        [ self generateAmplitudes ];
    }
}

@end
