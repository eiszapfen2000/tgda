#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "Input/NPEngineInput.h"
#import "NP.h"
#import "ODPreethamSkylight.h"

/*
sun disc implementation from

http://svn.gna.org/svn/pflex-framework/trunk/examples/flexray/lights/distant/preetham/preetham.cpp

*/

#define NUMBER_OF_SPECTRAL_COMPONENTS   41

static const double sun_spectral_radiance[NUMBER_OF_SPECTRAL_COMPONENTS] =
{
//in W.cm^{-2}.um^{-1}.sr^{-1}

1655.9,  1623.37, 2112.75, 2588.82, 2582.91, 2423.23, 2676.05, 2965.83, 3054.54, 3005.75,
3066.37, 2883.04, 2871.21, 2782.5,  2710.06, 2723.36, 2636.13, 2550.38, 2506.02, 2531.16,
2535.59, 2513.42, 2463.15, 2417.32, 2368.53, 2321.21, 2282.77, 2233.98, 2197.02, 2152.67,
2109.79, 2072.83, 2024.04, 1987.08, 1942.72, 1907.24, 1862.89, 1825.92,     0.0,     0.0,
0.0
};

static const double sun_spectral_k_o[NUMBER_OF_SPECTRAL_COMPONENTS] =
{
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.003, 0.006, 0.009,
0.014, 0.021, 0.03, 0.04, 0.048, 0.063, 0.075, 0.085, 0.103, 0.12,
0.12, 0.115, 0.125, 0.12, 0.105, 0.09, 0.079, 0.067, 0.057, 0.048,
0.036, 0.028, 0.023, 0.018, 0.014, 0.011, 0.01, 0.009, 0.007, 0.004,
0.0
};

static const double sun_spectral_k_wa[NUMBER_OF_SPECTRAL_COMPONENTS] =
{
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.016, 0.024, 0.0125, 1.0, 0.87, 0.061, 0.001, 1e-05, 1e-05,
0.0006
};

static const double sun_spectral_k_g[NUMBER_OF_SPECTRAL_COMPONENTS] =
{
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0.21,
0.0
};

static const double lambda_micrometer[NUMBER_OF_SPECTRAL_COMPONENTS] =
{
0.380, 0.390, 0.400, 0.410, 0.420, 0.430, 0.440, 0.450, 0.460, 0.470,
0.480, 0.490, 0.500, 0.510, 0.520, 0.530, 0.540, 0.550, 0.560, 0.570,
0.580, 0.590, 0.600, 0.610, 0.620, 0.630, 0.640, 0.650, 0.660, 0.670,
0.680, 0.690, 0.700, 0.710, 0.720, 0.730, 0.740, 0.750, 0.760, 0.770,
0.780
};

static const double xyz_matching_functions[3][NUMBER_OF_SPECTRAL_COMPONENTS] =
{
{0.000159952,0.0023616,0.0191097,0.084736,0.204492,0.314679,0.383734,0.370702,0.302273,0.195618,0.080507,0.016172,0.003816,0.037465,0.117749,0.236491,0.376772,0.529826,0.705224,0.878655,1.01416,1.11852,1.12399,1.03048,0.856297,0.647467,0.431567,0.268329,0.152568,0.0812606,0.0408508,0.0199413,0.00957688,0.00455263,0.00217496,0.00104476,0.000508258,0.000250969,0.00012639,6.45258E-05,3.34117E-05},																   {1.7364e-05,0.0002534,0.0020044,0.008756,0.021391,0.038676,0.062077,0.089456,0.128201,0.18519,0.253589,0.339133,0.460777,0.606741,0.761757,0.875211,0.961988,0.991761,0.99734,0.955552,0.868934,0.777405,0.658341,0.527963,0.398057,0.283493,0.179828,0.107633,0.060281,0.0318004,0.0159051,0.0077488,0.00371774,0.00176847,0.00084619,0.00040741,0.00019873,9.8428e-05,4.9737e-05,2.5486e-05,1.3249e-05},																		   {0.000704776,0.0104822,0.0860109,0.389366,0.972542,1.55348,1.96728,1.9948,1.74537,1.31756,0.772125,0.415254,0.218502,0.112044,0.060709,0.030451,0.013676,0.003988,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};

static Vector3 preetham_zenith_color(double turbidity, double thetaSun)
{
    // zenith color computation
    // A Practical Analytic Model for Daylight                              
    // page 22/23    

    #define CBQ(X)		((X) * (X) * (X))
    #define SQR(X)		((X) * (X))

    Vector3 zenithColor;

    zenithColor.x
        = ( 0.00166 * CBQ(thetaSun) - 0.00375  * SQR(thetaSun) +
            0.00209 * thetaSun + 0.0f) * SQR(turbidity) +
          (-0.02903 * CBQ(thetaSun) + 0.06377  * SQR(thetaSun) -
            0.03202 * thetaSun  + 0.00394) * turbidity +
          ( 0.11693 * CBQ(thetaSun) - 0.21196  * SQR(thetaSun) +
            0.06052 * thetaSun + 0.25886);

    zenithColor.y
        = ( 0.00275 * CBQ(thetaSun) - 0.00610  * SQR(thetaSun) +
            0.00317 * thetaSun + 0.0) * SQR(turbidity) +
          (-0.04214 * CBQ(thetaSun) + 0.08970  * SQR(thetaSun) -
            0.04153 * thetaSun  + 0.00516) * turbidity  +
          ( 0.15346 * CBQ(thetaSun) - 0.26756  * SQR(thetaSun) +
            0.06670 * thetaSun  + 0.26688);

    zenithColor.z
        = (4.0453 * turbidity - 4.9710) * 
          tan((4.0 / 9.0 - turbidity / 120.0) * (MATH_PI - 2.0 * thetaSun))
          - 0.2155 * turbidity + 2.4192;

    // convert kcd/m² to cd/m²
    zenithColor.z *= 1000.0;

    #undef SQR
    #undef CBQ

    return zenithColor;
}

static double digamma(double theta, double gamma, double ABCDE[5])
{
    const double cosTheta = cos(theta);
    const double cosGamma = cos(gamma);

    const double term_one = 1.0 + ABCDE[0] * exp(ABCDE[1] / cosTheta);
    const double term_two = 1.0 + ABCDE[2] * exp(ABCDE[3] * gamma) + (ABCDE[4] * cosGamma * cosGamma);

    return term_one * term_two;
}

static Vector3 sun_color(double turbidity, double thetaSun)
{
    // transmittance computation
    // A Practical Analytic Model for Daylight                              
    // page 21 

    const double thetaSunDegrees = MATH_RAD_TO_DEG * thetaSun;
    const double m = 1.0 / (thetaSunDegrees + 0.15 * pow(93.885 - thetaSunDegrees, -1.253));

    const double beta = 0.04608 * turbidity - 0.04586;
    const double l = 0.35;
    const double alpha = 1.3;
    const double w = 2.0;

    double spectralRadiance[NUMBER_OF_SPECTRAL_COMPONENTS];
    memset(spectralRadiance, 0, sizeof(spectralRadiance));

    for ( int32_t i = 0; i < NUMBER_OF_SPECTRAL_COMPONENTS; i++ )
    {
        const double lambda = lambda_micrometer[i];

		//apply each transmittance function, no particular order.
        double exponent = 0.0;

		//Rayleigh
		exponent += -0.008735 * pow(lambda, -4.08 * m);

		//Angstrom
		exponent += -beta * powf (lambda, - alpha * m);

		//ozone
		exponent += -sun_spectral_k_o[i] * l * m;

		//mixed gases absorption
		const double k_g = sun_spectral_k_g[i];
		exponent += (-1.41 * k_g * m) / pow(1.0 + 118.93 * k_g * m, 0.45);

		//water vapor absorption
		const double k_wa = sun_spectral_k_wa[i];
		exponent += (-0.2385 * k_wa * w * m) / pow(1.0 + 20.07 * k_wa * w * m, 0.45);

		spectralRadiance[i] = sun_spectral_radiance[i] * exp(exponent);
    }

	//the sun spectral radiances are expressed in cm^{-2} => we have to scale it by 10000 to obtain
	//the spectral radiance in W.m^{-2}.um^{-1}.sr^{-1},
	
	//the sun spectral radiances have wavelengthes expressed in micro-meters => we first have to convert it to wavelengthes
	//expressed in nanometers, as the color matching functions are expressed with wavelengthes in nanometers => we scale the
	//spectral radiance by 0.001. The delta_lambda is 10nm => the scaling factor for the wavelength change of unit is 0.01f	

    Vector3 XYZ = v3_zero();
	
	double delta = 10000.0 * 0.01;	

	for ( int32_t i = 0; i < NUMBER_OF_SPECTRAL_COMPONENTS; i++ )
    {
        XYZ.x += spectralRadiance[i] * xyz_matching_functions[0][i] * delta;
        XYZ.y += spectralRadiance[i] * xyz_matching_functions[1][i] * delta;
        XYZ.z += spectralRadiance[i] * xyz_matching_functions[2][i] * delta;
    }

    return XYZ;
}

@interface ODPreethamSkylight (Private)

- (void) processInput:(double)frameTime;
- (BOOL) generateRenderTarget:(NSError **)error;

@end

@implementation ODPreethamSkylight (Private)

- (void) processInput:(double)frameTime
{
    if ( [ sunZenithDistanceIncreaseAction active ] == YES )
    {
        thetaSun += (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunZenithDistanceDecreaseAction active ] == YES )
    {
        thetaSun -= (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunAzimuthIncreaseAction active ] == YES )
    {
        phiSun += (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    if ( [ sunAzimuthDecreaseAction active ] == YES )
    {
        phiSun -= (MATH_DEG_TO_RAD * 25.0 * frameTime);
    }

    thetaSun = MIN(MAX(0.0, thetaSun), MATH_PI_DIV_2);

    if ( phiSun > MATH_2_MUL_PI )
    {
        phiSun -= MATH_2_MUL_PI;
    }

    if ( phiSun < 0.0f )
    {
        phiSun += MATH_2_MUL_PI;
    }
}

- (BOOL) generateRenderTarget:(NSError **)error
{
    BOOL result
        = [ skylightTarget generate:NpRenderTargetColor
                              width:skylightResolution
                             height:skylightResolution
                        pixelFormat:NpTexturePixelFormatRGBA
                         dataFormat:NpTextureDataFormatFloat16
                      mipmapStorage:YES
                              error:error ];

    return
        result && [ sunlightTarget generate:NpRenderTargetColor
                                      width:skylightResolution
                                     height:skylightResolution
                                pixelFormat:NpTexturePixelFormatRGBA
                                 dataFormat:NpTextureDataFormatFloat16
                              mipmapStorage:YES
                                      error:error ];
}

@end


@implementation ODPreethamSkylight

- (id) init
{
    return [ self initWithName:@"ODPreethamSkylight" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    sunZenithDistanceIncreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunZenithDistanceIncrease" inputEvent:NpKeyboardKeypad2 ];

    sunZenithDistanceDecreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunZenithDistanceDecrease" inputEvent:NpKeyboardKeypad8 ];

    sunAzimuthIncreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunAzimuthIncrease" inputEvent:NpKeyboardKeypad4 ];

    sunAzimuthDecreaseAction
        = [[[ NP Input ] inputActions ]
                addInputActionWithName:@"SunAzimuthDecrease" inputEvent:NpKeyboardKeypad6 ];

    lastTurbidity = lastThetaSun = lastPhiSun = DBL_MAX;

    // turbidity must be in the range 2 - 6
    turbidity = 2.0;

    // thetaSun range 0 ... PI/2
    thetaSun = MATH_PI_DIV_4;

    // phi range 0 ... 2*PI
    phiSun = MATH_PI_DIV_2;

    directionToSun = v3_zero();
    sunColor = v3_zero();

    rtc = [[ NPRenderTargetConfiguration alloc] initWithName:@"Preetham RTC" ];
    skylightTarget = [[ NPRenderTexture alloc ] initWithName:@"Skylight Target" ];
    sunlightTarget = [[ NPRenderTexture alloc ] initWithName:@"Sunlight Target" ];

    lastSkylightResolution = INT_MAX;
    skylightResolution = 1024;

    effect = [[[ NP Graphics ] effects ] getAssetWithFileName:@"preetham.effect" ];
    ASSERT_RETAIN(effect);
    preetham = [ effect techniqueWithName:@"preetham" ];
    ASSERT_RETAIN(preetham);

    radiusInPixel_P        = [ effect variableWithName:@"radiusInPixel" ];
    sunHalfApparentAngle_P = [ effect variableWithName:@"sunHalfApparentAngle" ];

    directionToSun_P  = [ effect variableWithName:@"directionToSun" ];
    sunColor_P        = [ effect variableWithName:@"sunColor"       ];
    zenithColor_P     = [ effect variableWithName:@"zenithColor"    ];
    denominator_P     = [ effect variableWithName:@"denominator"    ];

    A_xyY_P = [ effect variableWithName:@"A" ];
    B_xyY_P = [ effect variableWithName:@"B" ];
    C_xyY_P = [ effect variableWithName:@"C" ];
    D_xyY_P = [ effect variableWithName:@"D" ];
    E_xyY_P = [ effect variableWithName:@"E" ];

    NSAssert(radiusInPixel_P != nil && sunHalfApparentAngle_P != nil 
             && directionToSun_P != nil && sunColor_P != nil
             && zenithColor_P != nil && denominator_P != nil && A_xyY_P != nil
             && B_xyY_P != nil && C_xyY_P != nil && D_xyY_P != nil && E_xyY_P != nil, @"");

    return self;
}

- (void) dealloc
{
    DESTROY(sunlightTarget);
    DESTROY(skylightTarget);
    DESTROY(rtc);
    DESTROY(preetham);
    DESTROY(effect);

    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunZenithDistanceDecreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthIncreaseAction ];
    [[[ NP Input ] inputActions ] removeInputAction:sunAzimuthDecreaseAction ];

    [ super dealloc ];
}

- (id < NPPTexture >) skylightTexture
{
    return [ skylightTarget texture ];
}

- (Vector3) directionToSun
{
    return directionToSun;
}

- (Vector3) sunColor
{
    return sunColor;
}

- (void) update:(double)frameTime
{
    [ self processInput:frameTime ];

    if ( turbidity != lastTurbidity || thetaSun != lastThetaSun
         || phiSun != lastPhiSun || skylightResolution != lastSkylightResolution )
    {
	    double ABCDE_x[5], ABCDE_y[5], ABCDE_Y[5];

	    ABCDE_x[0] = -0.01925 * turbidity - 0.25922;
	    ABCDE_x[1] = -0.06651 * turbidity + 0.00081;
	    ABCDE_x[2] = -0.00041 * turbidity + 0.21247;
	    ABCDE_x[3] = -0.06409 * turbidity - 0.89887;
	    ABCDE_x[4] = -0.00325 * turbidity + 0.04517;

	    ABCDE_y[0] = -0.01669 * turbidity - 0.26078;
	    ABCDE_y[1] = -0.09495 * turbidity + 0.00921;
	    ABCDE_y[2] = -0.00792 * turbidity + 0.21023;
	    ABCDE_y[3] = -0.04405 * turbidity - 1.65369;
	    ABCDE_y[4] = -0.01092 * turbidity + 0.05291;

	    ABCDE_Y[0] =  0.17872 * turbidity - 1.46303;
	    ABCDE_Y[1] = -0.35540 * turbidity + 0.42749;
	    ABCDE_Y[2] = -0.02266 * turbidity + 5.32505;
	    ABCDE_Y[3] =  0.12064 * turbidity - 2.57705;
	    ABCDE_Y[4] = -0.06696 * turbidity + 0.37027;

        Vector3 zenithColor = preetham_zenith_color(turbidity, thetaSun);

        Vector3 denominator;
        denominator.x = digamma(0.0, thetaSun, ABCDE_x);
        denominator.y = digamma(0.0, thetaSun, ABCDE_y);
        denominator.z = digamma(0.0, thetaSun, ABCDE_Y);

        Matrix3 lsRGB;
        M_EL(lsRGB, 0, 0) =  3.1338561;
        M_EL(lsRGB, 0, 1) = -0.9787684;
        M_EL(lsRGB, 0, 2) =  0.0719453;
        M_EL(lsRGB, 1, 0) = -1.6168667;
        M_EL(lsRGB, 1, 1) =  1.9161415;
        M_EL(lsRGB, 1, 2) = -0.2289914;
        M_EL(lsRGB, 2, 0) = -0.4906146;
        M_EL(lsRGB, 2, 1) =  0.0334540;
        M_EL(lsRGB, 2, 2) =  1.4052427;

        /*
        Vector3 nominatorSun;
        nominatorSun.x = digamma(thetaSun, 0.0, ABCDE_x);
        nominatorSun.y = digamma(thetaSun, 0.0, ABCDE_y);
        nominatorSun.z = digamma(thetaSun, 0.0, ABCDE_Y);

        Vector3 xyY;
        xyY.x = zenithColor.x * (nominatorSun.x / denominator.x);
        xyY.y = zenithColor.y * (nominatorSun.y / denominator.y);
        xyY.z = zenithColor.z * (nominatorSun.z / denominator.z);

        Vector3 XYZ;
        XYZ.x = (xyY.x / xyY.y) * xyY.z;        
        XYZ.y = xyY.z;
        XYZ.z = ((1.0 - xyY.x - xyY.y) / xyY.y) * xyY.z;

        Vector3 sColor = m3_mv_multiply(&lsRGB, &XYZ);
        */

        Vector3 sunXYZ = sun_color(turbidity, thetaSun);
        sunColor = m3_mv_multiply(&lsRGB, &sunXYZ);

        /*
        http://en.wikipedia.org/wiki/Solid_angle#Sun_and_Moon

        avg sun diameter 9.35×10−3 radians
        radius = 0.5 * diameter

        */

        double sunHalfApparentAngle = 0.00935 * 0.5;
        double sunDiskRadius = tan(sunHalfApparentAngle);
        double sunSolidAngle = sunDiskRadius * sunDiskRadius * MATH_PI;

        const double sinThetaSun = sin(thetaSun);
        const double cosThetaSun = cos(thetaSun);
        const double sinPhiSun = sin(phiSun);
        const double cosPhiSun = cos(phiSun);

        directionToSun.x = sinThetaSun * cosPhiSun;
        directionToSun.y = cosThetaSun;
        directionToSun.z = -sinThetaSun * sinPhiSun;

        const float halfSkyResolution = ((float)skylightResolution) / (2.0f);

        const float cStart = -halfSkyResolution;
        const float cEnd   =  halfSkyResolution;

        const Vector3 A = { ABCDE_x[0], ABCDE_y[0], ABCDE_Y[0] };
        const Vector3 B = { ABCDE_x[1], ABCDE_y[1], ABCDE_Y[1] };
        const Vector3 C = { ABCDE_x[2], ABCDE_y[2], ABCDE_Y[2] };
        const Vector3 D = { ABCDE_x[3], ABCDE_y[3], ABCDE_Y[3] };
        const Vector3 E = { ABCDE_x[4], ABCDE_y[4], ABCDE_Y[4] };

        Vector3 localDirectionToSun;
        localDirectionToSun.x = sinThetaSun * cosPhiSun;
        localDirectionToSun.y = sinThetaSun * sinPhiSun;
        localDirectionToSun.z = cosThetaSun;

        // set up coordinate system onsun disc
        Vector3 p_v1;

        if ( fabs(localDirectionToSun.x) > fabs(localDirectionToSun.y) )
        {
            double ilen = 1.0 / sqrt(localDirectionToSun.x * localDirectionToSun.x + localDirectionToSun.z * localDirectionToSun.z);
            p_v1 = (Vector3){-localDirectionToSun.z * ilen, 0.0, localDirectionToSun.x * ilen};
        }
        else
        {
            double ilen = 1.0 / sqrt(localDirectionToSun.y * localDirectionToSun.y + localDirectionToSun.z * localDirectionToSun.z);
            p_v1 = (Vector3){0.0, localDirectionToSun.z * ilen, -localDirectionToSun.y * ilen};
        }

        Vector3 p_v2 = v3_vv_cross_product(&localDirectionToSun, &p_v1);

        Vector3 dir;
        dir.x = localDirectionToSun.x + p_v1.x * sunDiskRadius + p_v2.x * sunDiskRadius;
        dir.y = localDirectionToSun.y + p_v1.y * sunDiskRadius + p_v2.y * sunDiskRadius;
        dir.z = localDirectionToSun.z + p_v1.z * sunDiskRadius + p_v2.z * sunDiskRadius;
        Vector3 dirN = v3_v_normalised(&dir);

        double sunCosHalfApparentAngle = v3_vv_dot_product(&dirN, &localDirectionToSun);
        double sunCosHalfApparentAngleInRange = MAX(MIN(sunCosHalfApparentAngle, 1.0), -1.0);
        sunHalfApparentAngle = MAX(sunHalfApparentAngle, acos(sunCosHalfApparentAngleInRange));

        //NSLog(@"%f %f %f", sunCosHalfApparentAngle, sunCosHalfApparentAngleInRange, sunHalfApparentAngle);

        [ radiusInPixel_P setFValue:halfSkyResolution ];
        [ sunHalfApparentAngle_P setValue:sunHalfApparentAngle ];
        [ directionToSun_P setValue:localDirectionToSun ];
        [ sunColor_P setValue:sunColor ];
        [ zenithColor_P setValue:zenithColor ];
        [ denominator_P setValue:denominator ];

        [ A_xyY_P setValue:A ];
        [ B_xyY_P setValue:B ];
        [ C_xyY_P setValue:C ];
        [ D_xyY_P setValue:D ];
        [ E_xyY_P setValue:E ];

        if ( skylightResolution != lastSkylightResolution )
        {
            [ rtc setWidth:skylightResolution  ];
            [ rtc setHeight:skylightResolution ];

            NSError * error = nil;
            if ( [ self generateRenderTarget:&error ] == NO )
            {
                NPLOG_ERROR(error);
            }
        }

        [ rtc bindFBO ];

        [ skylightTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        /*
        [ sunlightTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:1
                                      bindFBO:NO ];
        */

        [ rtc activateDrawBuffers ];
        [ rtc activateViewport ];

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

        [ preetham activate ];

        glBegin(GL_QUADS);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cStart, cStart);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cEnd, cStart);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f, -1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cEnd,  cEnd);
            glVertexAttrib2f(NpVertexStreamPositions,  1.0f,  1.0f);
            glVertexAttrib2f(NpVertexStreamTexCoords0, cStart,  cEnd);
            glVertexAttrib2f(NpVertexStreamPositions, -1.0f,  1.0f);
        glEnd();

        [ skylightTarget detach:NO ];

        [ rtc deactivate ];

        [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ skylightTarget texture ]];
        glGenerateMipmap(GL_TEXTURE_2D);
        [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

        lastTurbidity = turbidity;
        lastThetaSun  = thetaSun;
        lastPhiSun    = phiSun;

        lastSkylightResolution = skylightResolution;
    }
}

@end

