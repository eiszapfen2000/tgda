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

    if ( gaussianRNG != nil )
    {
        [ gaussianRNG release ];
        gaussianRNG = nil;
    }

    [ self resetFrequencySpectrum ];

    resOK = NO;
    sizeOK = NO;
    rngOK = NO;
}

- (BOOL) ready
{
    return ( resOK && sizeOK && rngOK );
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

- (void) checkForReadiness
{
    [ self checkSizeForReadiness ];
    [ self checkResolutionForReadiness ];
    [ self checkGaussianRNGForReadiness ];
}

- (void) setResX:(Int)newResX
{
    resX = newResX;

    [ self checkResolutionForReadiness ];
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
    Double m = -(resY / 2.0);
    m = m + (Double)index;

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
    amplitude = amplitude * pow(v2_vv_dot_product(&kNormalised, &windDirectionNormalised), 2.0);

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

//            NSLog(@"k: %f %f",k.x,k.y);

            a = sqrt([ self getAmplitudeAt:&k ]);

//            NSLog(@"a: %f",a);

			H0[j + resY * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			H0[j + resY * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;

//            NSLog(@"H0: %f %f", H0[j + resY * i][0],H0[j + resY * i][1]);
        }
    }
}

/*- (void) generateH
{
    int i, j, index;
    int ni, nj, nindex;
    ArFFTReal e1r, e1i, e2r, e2i, c1r, c1i, c2r, c2i;
    Vec2D k;
    double w;

    for ( Int i = 0; i < gridRes / 2; i++ )
    {
        for ( Int j = 0; j < gridRes; j++ )
        {
            index = i * gridRes + j;

            ni = (gridRes - 1) - i;
            nj = (gridRes - 1) - j;
            nindex = ni * gridRes + nj;

            XC(k) = [ self index_to_k : i ];
            //printf("index_to_k %f\n",XC(k));
            YC(k) = [ self index_to_k : j ];
            //printf("index_to_k %f\n",YC(k));

            w = [ self k_to_omega : &k ];
            //printf("k_to_omega %f\n",w);

            e1r = cos(w * t);
            e1i = sin(w * t);

            e2r = e1r;
            e2i = -e1i;

            c1r = H0r[index] * e1r - H0i[index] * e1i;
            c1i = H0r[index] * e1i + H0i[index] * e1r;

            c2r = H0r[nindex] * e2r - H0i[nindex] * e2i;
            c2i = H0r[nindex] * e2i + H0i[nindex] * e2r;

            Hr[index] = c1r + c2r;
            Hi[index] = c1i + c2i;
            //printf("Hr %f Hi %f\n",Hr[index],Hi[index]);

            Hr[nindex] = Hr[index];
            Hi[nindex] = -Hi[index];
            //printf("n Hr %f Hi %f\n",Hr[nindex],Hi[nindex]);
        }
    }
}*/

- (void) generateH
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

            /* complex multiplication
               x = a + i*b
               y = c + i*d
               xy = (ac-bd) + i(ad+bc)
            */

            // H0[indexForK] * exp(i*omega*t)
            H0expOmega[0] = H0[indexForK][0] * expOmega[0] - H0[indexForK][1] * expOmega[1];
            H0expOmega[1] = H0[indexForK][0] * expOmega[1] + H0[indexForK][1] * expOmega[0];

            // H0[indexForMinusK] * exp(-i*omega*t)
            H0expMinusOmega[0] = H0[indexForMinusK][0] * expMinusOmega[0] - H0[indexForMinusK][1] * expMinusOmega[1];
            H0expMinusOmega[1] = H0[indexForMinusK][0] * expMinusOmega[1] + H0[indexForMinusK][1] * expMinusOmega[0];

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
            frequencySpectrum[indexForMinusK][0] =  frequencySpectrum[indexForK][0];
            frequencySpectrum[indexForMinusK][1] = -frequencySpectrum[indexForK][1];
            //NSLog(@"Hc: %f %f",H[indexForMinusK][0],H[indexForMinusK][1]);
        }
    }    
} 

- (void) generateFrequencySpectrum
{
    if ( [ self ready ] == YES )
    {
        NSLog(@"start");
        [ self generateH0 ];
        [ self generateH ];
        NSLog(@"stop");
    }
}

@end
