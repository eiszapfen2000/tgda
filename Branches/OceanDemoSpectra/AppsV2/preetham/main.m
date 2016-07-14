#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdlib.h>
#import <time.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/Foundation.h>
#import "Log/NPLogFile.h"
#import "Core/Math/FRectangle.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Geometry/NPIMRendering.h"
#import "Graphics/Model/NPSUX2Model.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Effect/NPEffectVariableInt.h"
#import "Graphics/Font/NPFont.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/State/NPBlendingState.h"
#import "Graphics/State/NPCullingState.h"
#import "Graphics/State/NPDepthTestState.h"
#import "Graphics/NPViewport.h"
#import "Graphics/NPOrthographic.h"
#import "Input/NPKeyboard.h"
#import "Input/NPMouse.h"
#import "Input/NPInputAction.h"
#import "Input/NPInputActions.h"
#import "NP.h"
#import "GL/glew.h"
#import "GL/glfw.h"
#define ILUT_USE_OPENGL
#import "IL/ilut.h"

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
{0.000159952,0.0023616,0.0191097,0.084736,0.204492,0.314679,0.383734,0.370702,0.302273,0.195618,0.080507,0.016172,0.003816,0.037465,0.117749,0.236491,0.376772,0.529826,0.705224,0.878655,1.01416,1.11852,1.12399,1.03048,0.856297,0.647467,0.431567,0.268329,0.152568,0.0812606,0.0408508,0.0199413,0.00957688,0.00455263,0.00217496,0.00104476,0.000508258,0.000250969,0.00012639,6.45258E-05,3.34117E-05},
{1.7364e-05,0.0002534,0.0020044,0.008756,0.021391,0.038676,0.062077,0.089456,0.128201,0.18519,0.253589,0.339133,0.460777,0.606741,0.761757,0.875211,0.961988,0.991761,0.99734,0.955552,0.868934,0.777405,0.658341,0.527963,0.398057,0.283493,0.179828,0.107633,0.060281,0.0318004,0.0159051,0.0077488,0.00371774,0.00176847,0.00084619,0.00040741,0.00019873,9.8428e-05,4.9737e-05,2.5486e-05,1.3249e-05},
{0.000704776,0.0104822,0.0860109,0.389366,0.972542,1.55348,1.96728,1.9948,1.74537,1.31756,0.772125,0.415254,0.218502,0.112044,0.060709,0.030451,0.013676,0.003988,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
};

IVector2 widgetSize;
IVector2 mousePosition;

NpMouseState mouseState;
NpKeyboardState keyboardState;

static void GLFWCALL keyboard_callback(int key, int state)
{
    keyboardState.keys[key] = state;
}

static void GLFWCALL mouse_pos_callback(int x, int y)
{
    mousePosition.x = x;
    mousePosition.y = y;
}

static void mouse_button_callback(int button, int state)
{
    mouseState.buttons[button] = state;
}

static void GLFWCALL mouse_wheel_callback(int wheel)
{
    mouseState.scrollWheel = wheel;
}

static void GLFWCALL window_resize_callback(int width, int height)
{
    widgetSize.x = width;
    widgetSize.y = height;
}

static Vector3 preetham_zenith(double turbidity, double thetaSun)
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

static double preetham_digamma(double theta, double gamma, double ABCDE[5])
{
    const double cosTheta = cos(theta);
    const double cosGamma = cos(gamma);

    const double term_one = 1.0 + ABCDE[0] * exp(ABCDE[1] / cosTheta);
    const double term_two = 1.0 + ABCDE[2] * exp(ABCDE[3] * gamma) + (ABCDE[4] * cosGamma * cosGamma);

    return term_one * term_two;
}

static Vector3 compute_sun_color(double turbidity, double thetaSun)
{
    // transmittance computation
    // A Practical Analytic Model for Daylight                              
    // page 21 

    const double thetaSunDegrees = MATH_RAD_TO_DEG * thetaSun;
    double m = 1.0 / (cos(thetaSun) + 0.15 * pow(93.885 - thetaSunDegrees, -1.253));

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
		//exponent += (-0.008735 * pow(lambda, -4.08 * m));

		//Angstrom
		exponent += (-beta * pow(lambda, - alpha * m));

		//ozone
		exponent += (-sun_spectral_k_o[i] * l * m);

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
	
	double delta = 10000.0 * 0.001 * 10.0;

	for ( int32_t i = 0; i < NUMBER_OF_SPECTRAL_COMPONENTS; i++ )
    {
        XYZ.x += spectralRadiance[i] * xyz_matching_functions[0][i] * delta;
        XYZ.y += spectralRadiance[i] * xyz_matching_functions[1][i] * delta;
        XYZ.z += spectralRadiance[i] * xyz_matching_functions[2][i] * delta;
    }

    return XYZ;
}

static Vector3 xyY_to_XYZ(Vector3 xyY)
{
    assert(xyY.z > 0.0);

    Vector3 XYZ;
    XYZ.x = (xyY.x / xyY.y) * xyY.z;
    XYZ.y = xyY.z;
    XYZ.z = ((1.0 - xyY.x - xyY.y) / xyY.y) * xyY.z;

    return XYZ;
}

static Vector3 XYZ_to_xyY(Vector3 XYZ)
{
    assert(!(XYZ.x == 0.0 && XYZ.y == 0.0 && XYZ.z ));

    Vector3 xyY;
    xyY.x = XYZ.x / (XYZ.x + XYZ.y + XYZ.z);
    xyY.y = XYZ.y / (XYZ.x + XYZ.y + XYZ.z);
    xyY.z = XYZ.y;

    return xyY;
}

static Vector3 Lab_to_XYZ(Vector3 Lab, Vector3 RefWhiteXYZ)
{
	const double epsilon = 216.0 / 24389.0;
	const double kappa = 24389.0 / 27.0;

	const double fy = (Lab.x + 16.0) / 116.0;
	const double fx = (Lab.y / 500.0) + fy;
	const double fz = fy - (Lab.z / 200.0);

	const double fx3 = pow(fx, 3.0);
	const double fy3 = pow(fy, 3.0);
	const double fz3 = pow(fz, 3.0);

	const double xr = (fx3 > epsilon) ? fx3 : ((116.0*fx - 16.0) / kappa);
	const double yr = (Lab.x > (kappa*epsilon)) ? fy3 : (Lab.x / kappa);
	const double zr = (fz3 > epsilon) ? fz3 : ((116.0*fz - 16.0) / kappa);

	Vector3 XYZ;
	XYZ.x = xr * RefWhiteXYZ.x;
	XYZ.y = yr * RefWhiteXYZ.y;
	XYZ.z = zr * RefWhiteXYZ.z;

	return XYZ;
}

static Vector3 XYZ_to_Lab(Vector3 XYZ, Vector3 RefWhiteXYZ)
{
	const double epsilon = 216.0 / 24389.0;
	const double kappa = 24389.0 / 27.0;

	const double xr = XYZ.x / RefWhiteXYZ.x;
	const double yr = XYZ.y / RefWhiteXYZ.y;
	const double zr = XYZ.z / RefWhiteXYZ.z;

	const double fx = (xr > epsilon) ? pow(xr, 1.0/3.0) : ((kappa*xr + 16.0) / 116.0);
	const double fy = (yr > epsilon) ? pow(yr, 1.0/3.0) : ((kappa*yr + 16.0) / 116.0);
	const double fz = (zr > epsilon) ? pow(zr, 1.0/3.0) : ((kappa*zr + 16.0) / 116.0);

	Vector3 Lab;
	Lab.x = 116.0 * fy - 16.0;
	Lab.y = 500.0 * (fx - fy);
	Lab.z = 200.0 * (fy - fz);

	return Lab;
}

/**
 * reference white in XYZ coordinates
 */
static const Vector3 D50 = {96.4212, 100.0, 82.5188};
static const Vector3 D55 = {95.6797, 100.0, 92.1481};
static const Vector3 D65 = {95.0429, 100.0, 108.8900};
static const Vector3 D75 = {94.9722, 100.0, 122.6394};

/**
 * reference white in xyY coordinates
 */
static const Vector3 chromaD50 = {0.3457, 0.3585, 100.0};
static const Vector3 chromaD55 = {0.3324, 0.3474, 100.0};
static const Vector3 chromaD65 = {0.3127, 0.3290, 100.0};
static const Vector3 chromaD75 = {0.2990, 0.3149, 100.0};

static NSString * const NPGraphicsStartupError = @"NPEngineGraphics failed to start up. Consult %@/np.log for details.";

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    // Initialise GLFW
    if( !glfwInit() )
    {
        NSLog(@"Failed to initialize GLFW");
        exit(EXIT_FAILURE);
    }

    // do not allow window resizing
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_TRUE);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 3);
    // glew needs compatibility profile
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_COMPAT_PROFILE);
    glfwOpenWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
    
    // Open a window and create its OpenGL context
    if( !glfwOpenWindow( 1024, 1024, 0, 0, 0, 0, 0, 0, GLFW_WINDOW ) )
    {
        NSLog(@"Failed to open GLFW window");
        glfwTerminate();
        exit(EXIT_FAILURE);
    }

    // initialise keyboard and mouse state
    keyboardstate_reset(&keyboardState);
    mousestate_reset(&mouseState);
    mousePosition.x = mousePosition.y = 0;

    // VSync
    glfwSwapInterval(0);
    // do not poll events on glfwSwapBuffers
    glfwDisable(GLFW_AUTO_POLL_EVENTS);
    // register keyboard callback
    glfwSetKeyCallback(keyboard_callback);
    // register mouse callbacks
    glfwSetMousePosCallback(mouse_pos_callback);
    glfwSetMouseButtonCallback(mouse_button_callback);
    glfwSetMouseWheelCallback(mouse_wheel_callback);
    // callback for window resizes
    glfwSetWindowSizeCallback(window_resize_callback);

    glClearDepth(1);
    glClearStencil(0);
    glClearColor(0.0, 0.0, 0.0, 0.0);

    // create and register log file
    NPLogFile * logFile = AUTORELEASE([[ NPLogFile alloc ] init ]);
    [[ NP Log ] addLogger:logFile ];

    // start up GFX
    if ( [[ NP Graphics ] startup ] == NO )
    {
        NSLog(NPGraphicsStartupError, NSHomeDirectory());
        exit(EXIT_FAILURE);
    }

    [[ NP Graphics ] checkForGLErrors ];
    [[[ NP Core ] timer ] reset ];

    glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);

    [[ NP Graphics ] checkForGLErrors ];

    // adopt viewport to current widget size
    NPViewport * viewport = [[ NP Graphics ] viewport ];
    [ viewport setWidgetWidth:widgetSize.x  ];
    [ viewport setWidgetHeight:widgetSize.y ];
    [ viewport reset ];

    NSAutoreleasePool * rPool = [ NSAutoreleasePool new ];

    const uint32_t skyResolution = 1024;

    NPRenderTargetConfiguration * rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC"  ];
    NPRenderTexture * preethamTarget  = [[ NPRenderTexture alloc ] initWithName:@"Preetham Target"  ];
    NPRenderTexture * luminanceTarget = [[ NPRenderTexture alloc ] initWithName:@"Luminance Target" ];

    [ preethamTarget generate:NpRenderTargetColor
                        width:skyResolution
                       height:skyResolution
                  pixelFormat:NpTexturePixelFormatRGBA
                   dataFormat:NpTextureDataFormatFloat16
                mipmapStorage:NO
                        error:NULL ];

    [ luminanceTarget generate:NpRenderTargetColor
                         width:skyResolution
                        height:skyResolution
                   pixelFormat:NpTexturePixelFormatR
                    dataFormat:NpTextureDataFormatFloat16
                 mipmapStorage:YES
                         error:NULL ];

    [ rtc setWidth:skyResolution  ];
    [ rtc setHeight:skyResolution ];


    NPEffect * effect
        = [[[ NPEngineGraphics instance ]
                effects ] getAssetWithFileName:@"default.effect" ];

    assert( effect != nil );

    RETAIN(effect);

    NPEffectTechnique * preetham = [ effect techniqueWithName:@"preetham" ];
    NPEffectTechnique * preethamSunDisc = [ effect techniqueWithName:@"preetham_sundisc" ];
    NPEffectTechnique * texture  = [ effect techniqueWithName:@"texture"  ];

    NPEffectTechnique * logLuminance
        = [ effect techniqueWithName:@"linear_sRGB_to_log_luminance" ];

    NPEffectTechnique * tonemap
        = [ effect techniqueWithName:@"tonemap_reinhard" ];

    assert(preetham != nil && texture != nil && logLuminance != nil && tonemap != nil);

    RETAIN(preetham);
    RETAIN(texture);
    RETAIN(logLuminance);
    RETAIN(tonemap);

    NPEffectVariableFloat * radiusInPixel_P
        = [ effect variableWithName:@"radiusInPixel" ];

    NPEffectVariableFloat3 * directionToSun_P
        = [ effect variableWithName:@"directionToSun" ];

    NPEffectVariableFloat3 * sunColor_P
        = [ effect variableWithName:@"sunColor" ];

    NPEffectVariableFloat * sunHalfApparentAngle_P
        = [ effect variableWithName:@"sunHalfApparentAngle" ];

    NPEffectVariableFloat3 * zenithColor_P
        = [ effect variableWithName:@"zenithColor" ];

    NPEffectVariableFloat3 * denominator_P
        = [ effect variableWithName:@"denominator" ];

    NPEffectVariableFloat3 * A_xyY_P = [ effect variableWithName:@"A" ];
    NPEffectVariableFloat3 * B_xyY_P = [ effect variableWithName:@"B" ];
    NPEffectVariableFloat3 * C_xyY_P = [ effect variableWithName:@"C" ];
    NPEffectVariableFloat3 * D_xyY_P = [ effect variableWithName:@"D" ];
    NPEffectVariableFloat3 * E_xyY_P = [ effect variableWithName:@"E" ];

    NPEffectVariableFloat3 * irradiance_P = [ effect variableWithName:@"irradiance" ];

    NPEffectVariableFloat * key_P = [ effect variableWithName:@"key" ];
    NPEffectVariableInt   * averageLuminanceLevel_P = [ effect variableWithName:@"averageLuminanceLevel" ];
    NPEffectVariableFloat * whiteLuminance_P = [ effect variableWithName:@"whiteLuminance" ];

    assert(A_xyY_P != nil && B_xyY_P != nil && C_xyY_P != nil && D_xyY_P != nil
           && E_xyY_P != nil && radiusInPixel_P != nil && directionToSun_P != nil
           && sunColor_P != nil && sunHalfApparentAngle_P != nil
           && zenithColor_P != nil && denominator_P != nil && irradiance_P != nil
           && key_P != nil && averageLuminanceLevel_P != nil && whiteLuminance_P != nil);

    NPInputAction * leftClick
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"LeftClick"
                            inputEvent:NpMouseButtonLeft ];

    NPInputAction * rightClick
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"RightClick"
                            inputEvent:NpMouseButtonRight ];

    NPInputAction * wheelUp
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"WheelUp"
                            inputEvent:NpMouseWheelUp ];

    NPInputAction * wheelDown
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"WheelDown"
                            inputEvent:NpMouseWheelDown ];

    NPInputAction * irradiance
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"Irradiance"
                            inputEvent:NpKeyboardI ];

    NPInputAction * sunDisc
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"SunDisc"
                            inputEvent:NpKeyboardD ];

    NPInputAction * tmap
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"Tonemap"
                            inputEvent:NpKeyboardT ];

    NPInputAction * screenShot
        = [[[ NP Input ] inputActions ] 
                addInputActionWithName:@"Screenshot"
                            inputEvent:NpKeyboardS ];
	

    RETAIN(leftClick);
    RETAIN(rightClick);
    RETAIN(wheelUp);
    RETAIN(wheelDown);
	RETAIN(irradiance);
	RETAIN(sunDisc);
	RETAIN(tmap);
	RETAIN(screenShot);

    DESTROY(rPool);

    BOOL running = YES;

    // preetham
    double turbidity = 2.0;
    double phiSun = MATH_PI_DIV_2;
    double thetaSun = MATH_PI_DIV_4;

    // tonemap
    double a = 0.05;
    double L_white = 2.0;

    const float halfSkyResolution = ((float)skyResolution) / (2.0f);

    const float cStart = -halfSkyResolution;
    const float cEnd   =  halfSkyResolution;

    BOOL modified = YES;
	BOOL useIrradiance = YES;
	BOOL renderSunDisc = YES;
	BOOL tonemapping = YES;
	Vector3 irradiance_XYZ = v3_zero();

	FRectangle vertices;
	vertices.min.x = vertices.min.y = -1.0;
	vertices.max.x = vertices.max.y =  1.0;

	FRectangle texCoords;
	texCoords.min.x = texCoords.min.y = 0.0;
	texCoords.max.x = texCoords.max.y = 1.0;

    // run loop
    while ( running )
    {
        // create an autorelease pool for every run-loop iteration
        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        // push current keyboard and mouse state into NPInput
        [[[ NP Input ] keyboard ] setKeyboardState:&keyboardState ];
        [[[ NP Input ] mouse ] setMouseState:&mouseState ];
        [[[ NP Input ] mouse ] setMousePosition:mousePosition ];

        // update NPEngineInput's internal state (actions)
        [[ NP Input ] update ];

        // update NPEngineCore
        [[ NP Core ] update ];

        // get current frametime
        const double frameTime = [[[ NP Core ] timer ] frameTime ];
        const int32_t fps = [[[ NP Core ] timer ] fps ];

        //NSLog(@"%lf %d", frameTime, fps);

        if ([ wheelUp activated ] == YES )
        {
            thetaSun += MATH_DEG_TO_RAD * 3.0;
            modified = YES;
        }

        if ([ wheelDown activated ] == YES )
        {
            thetaSun -= MATH_DEG_TO_RAD * 3.0;
            modified = YES;
        }

        if ( [ leftClick activated ] == YES )
        {
            int32_t x = [[[ NP Input ] mouse ] x ];
            int32_t y = [[[ NP Input ] mouse ] y ];
            y = widgetSize.y - y - 1;

            double dx = 0.0;
            double dy = 0.0;

            if ( x < (widgetSize.x / 2))
            {
                dx = (double)(x - (widgetSize.x / 2));
            }
            else
            {
                dx = (double)(x - (widgetSize.x / 2) + 1);
            }

            if ( y < (widgetSize.y / 2))
            {
                dy = (double)(y - (widgetSize.y / 2));
            }
            else
            {
                dy = (double)(y - (widgetSize.y / 2) + 1);
            }

            phiSun = atan2(dy, dx);
            modified = YES;
        }

        if ([ irradiance deactivated ] == YES )
        {
	        useIrradiance = !useIrradiance;
	        irradiance_XYZ = v3_zero();
	        modified = YES;
        }

        if ([ sunDisc deactivated ] == YES )
        {
	        renderSunDisc = !renderSunDisc;
        }

        if ([ tmap deactivated ] == YES )
        {
	        tonemapping = !tonemapping;
        }

        thetaSun = MIN(thetaSun, MATH_PI_DIV_2);
        thetaSun = MAX(thetaSun, 0.0);

        if ( modified == YES )
        {
            NSLog(@"phi:%lf theta:%lf", phiSun * MATH_RAD_TO_DEG, thetaSun * MATH_RAD_TO_DEG);
        }

        double sunHalfApparentAngle = 0.00935 * 0.5;
        //double sunHalfApparentAngle = 0.25 * MATH_PI / 360.0;
		//double sunHalfApparentAngle = 0.25 * MATH_DEG_TO_RAD;
        double sunDiskRadius = tan(sunHalfApparentAngle);

        //
        const double sinThetaSun = sin(thetaSun);
        const double cosThetaSun = cos(thetaSun);
        const double sinPhiSun = sin(phiSun);
        const double cosPhiSun = cos(phiSun);

        Vector3 directionToSun;
        directionToSun.x = sinThetaSun * cosPhiSun;
        directionToSun.y = sinThetaSun * sinPhiSun;
        directionToSun.z = cosThetaSun;


        Vector3 p_v1, p_v2;
        if ( fabs(directionToSun.x) > fabs(directionToSun.y) )
        {
            double ilen = 1.0 / sqrt(directionToSun.x * directionToSun.x + directionToSun.z * directionToSun.z);
            p_v1 = (Vector3){-directionToSun.z * ilen, 0.0, directionToSun.x * ilen};
        }
        else
        {
            double ilen = 1.0 / sqrt(directionToSun.y * directionToSun.y + directionToSun.z * directionToSun.z);
            p_v1 = (Vector3){0.0, directionToSun.z * ilen, -directionToSun.y * ilen};
        }

        p_v2 = v3_vv_cross_product(&directionToSun, &p_v1);

        Vector3 dir;
        dir.x = directionToSun.x + p_v1.x * sunDiskRadius + p_v2.x * sunDiskRadius;
        dir.y = directionToSun.y + p_v1.y * sunDiskRadius + p_v2.y * sunDiskRadius;
        dir.z = directionToSun.z + p_v1.z * sunDiskRadius + p_v2.z * sunDiskRadius;
        Vector3 dirN = v3_v_normalised(&dir);

        double sunCosHalfApparentAngle = v3_vv_dot_product(&dirN, &directionToSun);
        sunHalfApparentAngle = MAX(sunHalfApparentAngle, acos(sunCosHalfApparentAngle));

        // Preetham Skylight Zenith color
        // xyY space, cd/m²
        Vector3 zenithColor_xyY = preetham_zenith(turbidity, thetaSun);

        // Preetham Skylight sun disc color
        // XYZ
        Vector3 sunColor_XYZ = compute_sun_color(turbidity, thetaSun);

        // Page 22/23 compute coefficients
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

        // Page 9 eq. 4, precompute F(0, thetaSun)
        Vector3 denominator;
        denominator.x = preetham_digamma(0.0, thetaSun, ABCDE_x);
        denominator.y = preetham_digamma(0.0, thetaSun, ABCDE_y);
        denominator.z = preetham_digamma(0.0, thetaSun, ABCDE_Y);

        if ( useIrradiance == YES && modified == YES)
		{
			irradiance_XYZ = v3_zero();

		    const double phiStep   = 1.0 * MATH_DEG_TO_RAD;
		    const double thetaStep = 1.0 * MATH_DEG_TO_RAD;

		    for (double phi = 0.0; phi < MATH_2_MUL_PI; phi += phiStep)
		    {
		        for (double theta = 0.0; theta < MATH_PI_DIV_4; theta += thetaStep)
		        {
		            const double sinTheta = sin(theta);
		            const double cosTheta = cos(theta);
		            const double sinPhi = sin(phi);
		            const double cosPhi = cos(phi);

		            Vector3 v;
		            v.x = sinTheta * cosPhi;
		            v.y = sinTheta * sinPhi;
		            v.z = cosTheta;
		            // float cosGamma = clamp(dot(v, directionToSun), -1.0, 1.0);
		            double cosGamma = v3_vv_dot_product(&directionToSun, &v);
		            cosGamma = MAX(MIN(cosGamma, 1.0), -1.0);
		            double gamma = acos(cosGamma);

		            Vector3 nominator;
		            nominator.x = preetham_digamma(theta, gamma, ABCDE_x);
		            nominator.y = preetham_digamma(theta, gamma, ABCDE_y);
		            nominator.z = preetham_digamma(theta, gamma, ABCDE_Y);

		            Vector3 xyY;
		            xyY.x = zenithColor_xyY.x * (nominator.x / denominator.x);
		            xyY.y = zenithColor_xyY.y * (nominator.y / denominator.y);
		            xyY.z = zenithColor_xyY.z * (nominator.z / denominator.z);

		            double n_dot_v = v3_vv_dot_product(NP_WORLD_Z_AXIS, &v);

		            Vector3 XYZ = xyY_to_XYZ(xyY);
		            irradiance_XYZ.x += XYZ.x * phiStep * thetaStep * n_dot_v;
		            irradiance_XYZ.y += XYZ.y * phiStep * thetaStep * n_dot_v;
		            irradiance_XYZ.z += XYZ.z * phiStep * thetaStep * n_dot_v;
		        }
		    }
		}

		modified = NO;

        Vector3 nominatorSun;
        nominatorSun.x = preetham_digamma(thetaSun, 0.0, ABCDE_x);
        nominatorSun.y = preetham_digamma(thetaSun, 0.0, ABCDE_y);
        nominatorSun.z = preetham_digamma(thetaSun, 0.0, ABCDE_Y);

        Vector3 sun_xyY;
        sun_xyY.x = zenithColor_xyY.x * (nominatorSun.x / denominator.x);
        sun_xyY.y = zenithColor_xyY.y * (nominatorSun.y / denominator.y);
        sun_xyY.z = zenithColor_xyY.z * (nominatorSun.z / denominator.z);

        Vector3 sun_XYZ = xyY_to_XYZ(sun_xyY);
		Vector3 sun_Lab = XYZ_to_Lab(sun_XYZ, D50);
		Vector3 sun_XYZ_from_Lab = Lab_to_XYZ(sun_Lab, D50);

		Vector3 sunColor_Lab = XYZ_to_Lab(sunColor_XYZ, D50);

		Vector3 combined_Lab;
		//combined_Lab.x = MAX(sunColor_Lab.x, sun_Lab.x*2.0);
		combined_Lab.x = MAX(sun_Lab.x, sunColor_Lab.x);
		combined_Lab.y = sun_Lab.y;
		combined_Lab.z = sun_Lab.z;

		Vector3 combined_XYZ = Lab_to_XYZ(combined_Lab, D50);

        const FVector3 A = { ABCDE_x[0], ABCDE_y[0], ABCDE_Y[0] };
        const FVector3 B = { ABCDE_x[1], ABCDE_y[1], ABCDE_Y[1] };
        const FVector3 C = { ABCDE_x[2], ABCDE_y[2], ABCDE_Y[2] };
        const FVector3 D = { ABCDE_x[3], ABCDE_y[3], ABCDE_Y[3] };
        const FVector3 E = { ABCDE_x[4], ABCDE_y[4], ABCDE_Y[4] };

        [ A_xyY_P setFValue:A ];
        [ B_xyY_P setFValue:B ];
        [ C_xyY_P setFValue:C ];
        [ D_xyY_P setFValue:D ];
        [ E_xyY_P setFValue:E ];
        [ irradiance_P setValue:irradiance_XYZ ];

        [ radiusInPixel_P setFValue:halfSkyResolution ];
        [ directionToSun_P setValue:directionToSun ];
        [ sunColor_P setValue:sunColor_XYZ ];
		//[ sunColor_P setValue:sun_XYZ ];
		//[ sunColor_P setValue:combined_XYZ ];
        [ sunHalfApparentAngle_P setValue:sunHalfApparentAngle ];
        [ zenithColor_P setValue:zenithColor_xyY ];
        [ denominator_P setValue:denominator ];

        // clear preetham target
        [ rtc bindFBO ];

        [ preethamTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

        [ rtc activateDrawBuffers ];
        [ rtc activateViewport ];

        const float avgFresnel = 0.17;
        Vector3 averageReflectance_XYZ = v3_sv_scaled(avgFresnel / MATH_PI, &irradiance_XYZ);

        Matrix3 XYZ2LinearsRGB_D50;
        M_EL(XYZ2LinearsRGB_D50,0,0) =  3.1338561; M_EL(XYZ2LinearsRGB_D50,1,0) = -1.6168667; M_EL(XYZ2LinearsRGB_D50,2,0) = -0.4906146;
        M_EL(XYZ2LinearsRGB_D50,0,1) = -0.9787684; M_EL(XYZ2LinearsRGB_D50,1,1) =  1.9161415; M_EL(XYZ2LinearsRGB_D50,2,1) =  0.0334540;
        M_EL(XYZ2LinearsRGB_D50,0,2) =  0.0719453; M_EL(XYZ2LinearsRGB_D50,1,2) = -0.2289914; M_EL(XYZ2LinearsRGB_D50,2,2) =  1.4052427;

        Vector3 averageReflectance_LinearsRGB = m3_mv_multiply(&XYZ2LinearsRGB_D50, &averageReflectance_XYZ);

		const FVector4 clearColor 
			= {
				.x = averageReflectance_LinearsRGB.x,
			    .y = averageReflectance_LinearsRGB.y,
			    .z = averageReflectance_LinearsRGB.z,
			    .w = 0.0f
			  };

        [[ NP Graphics ] clearDrawBuffer:0 color:clearColor ];

		if ( renderSunDisc == YES )
		{
			[ preethamSunDisc activate ];
		}
		else
		{
	        [ preetham activate ];
		}

		[ NPIMRendering
			renderFRectangle:vertices
			   primitiveType:NpPrimitiveQuads ];

        [ preethamTarget detach:NO ];

        [ luminanceTarget
            attachToRenderTargetConfiguration:rtc
                             colorBufferIndex:0
                                      bindFBO:NO ];

		const FVector4 zeroColor = {.x = 0.0f, .y = 0.0f, .z = 0.0f, .w = 0.0f};
        [[ NP Graphics ] clearDrawBuffer:0 color:clearColor ];

        [[[ NP Graphics ] textureBindingState ] setTexture:[ preethamTarget texture ] texelUnit:0 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        [ logLuminance activate ];

		[ NPIMRendering
			renderFRectangle:vertices
				   texCoords:texCoords
			   primitiveType:NpPrimitiveQuads ];

        [ luminanceTarget detach:NO ];

        [ rtc deactivate ];

        // generate logluminance mipmap pyramid
        // highest level contains average log luminance
        [[[ NP Graphics ] textureBindingState ] setTextureImmediately:[ luminanceTarget texture ] ];
        glGenerateMipmap(GL_TEXTURE_2D);
        [[[ NP Graphics ] textureBindingState ] restoreOriginalTextureImmediately ];

        // activate culling, depth write and depth test
        NPCullingState * cullingState = [[[ NP Graphics ] stateConfiguration ] cullingState ];
        NPBlendingState * blendingState = [[[ NP Graphics ] stateConfiguration ] blendingState ];
        NPDepthTestState * depthTestState = [[[ NP Graphics ] stateConfiguration ] depthTestState ];

        [ blendingState  setEnabled:NO ];
        [ cullingState   setCullFace:NpCullfaceBack ];
        [ cullingState   setEnabled:YES ];
        [ depthTestState setWriteEnabled:YES ];
        [ depthTestState setEnabled:YES ];
        [[[ NP Graphics ] stateConfiguration ] activate ];

        // clear context framebuffer
        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:YES stencilBuffer:NO ];

        [[[ NP Graphics ] textureBindingState ] clear ];
        [[[ NP Graphics ] textureBindingState ] setTexture:[ preethamTarget  texture ] texelUnit:0 ];
        [[[ NP Graphics ] textureBindingState ] setTexture:[ luminanceTarget texture ] texelUnit:1 ];
        [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

        const int32_t numberOfLevels
            = 1 + (int32_t)floor(logb(skyResolution));

        [ key_P setValue:a ];
        [ whiteLuminance_P setValue:L_white ];
        [ averageLuminanceLevel_P setValue:(numberOfLevels - 1) ];

		if ( tonemapping == YES )
		{
			[ tonemap activate ];
		}
		else
		{
	        [ texture activate ];
		}

		[ NPIMRendering
			renderFRectangle:vertices
				   texCoords:texCoords
			   primitiveType:NpPrimitiveQuads ];

        // check for GL errors
        [[ NP Graphics ] checkForGLErrors ];

		if ( [screenShot deactivated] == YES )
		{
			NSLog(@"CHeeeers");
			ilutGLScreenie();
		}

        // swap front and back rendering buffers
        glfwSwapBuffers();

        // poll events, callbacks for mouse and keyboard
        // are called automagically
        // we need to call this here, because only this way
        // window closing events are processed
        glfwPollEvents();

        // check if window was closed
        running = running && glfwGetWindowParam( GLFW_OPENED );

        // kill autorelease pool
        DESTROY(innerPool);
    }

    DESTROY(leftClick);
    DESTROY(rightClick);
    DESTROY(wheelUp);
    DESTROY(wheelDown);
	DESTROY(irradiance);
	DESTROY(sunDisc);
	DESTROY(tmap);
	DESTROY(screenShot);

    DESTROY(tonemap);
    DESTROY(logLuminance);
    DESTROY(preetham);
    DESTROY(texture);
    DESTROY(effect);

    DESTROY(rtc);
    DESTROY(preethamTarget);
    DESTROY(luminanceTarget);

    // Shutdown NPGraphics, deallocates a lot of stuff
    [[ NP Graphics ] shutdown ];

    // Close OpenGL window and terminate GLFW
    glfwTerminate();

    // Kill singletons by force, sending them
    // "release" would have no effect
    
    [[ NP Input    ] dealloc ];
    [[ NP Graphics ] dealloc ];
    [[ NP Core     ] dealloc ];
    [[ NP Log      ] dealloc ];
    

    DESTROY(pool);

    return EXIT_SUCCESS;
}

