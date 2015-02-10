#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdio.h>
#import <stdlib.h>
#import <time.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/Foundation.h>
#import "Log/NPLogFile.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Geometry/NPVertexArray.h"
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

static double energy_pm_wave_frequency(double omega, double U10)
{
    if (omega == 0.0)
    {
        return 0.0;
    }

    const double g = 9.81;
    const double alpha = 0.0081;
    const double omega_p = (0.855 * g / U10);

    const double exponent = (-5.0/4.0) * pow(omega_p / omega, 4.0);
    const double Theta = ((alpha*g*g) / pow(omega, 5.0)) * exp(exponent);

    return Theta;
}

static double energy_pm_wave_number(double k, double U10)
{
    if (k == 0.0)
    {
        return 0.0;
    }

    const double g = 9.81;
    const double omega = sqrt(k * g);
    const double Theta = energy_pm_wave_frequency(omega, U10);
    const double Theta_k = Theta * 0.5 * (g / omega);

    return Theta_k;
}

static double energy_pm_wave_vector(Vector2 k_wv, double U10)
{
    const double kSquareLength = k_wv.x * k_wv.x + k_wv.y * k_wv.y;

    if (kSquareLength == 0.0)
    {
        return 0.0;
    }

    const double k = sqrt(kSquareLength);
    const double Theta_k = energy_pm_wave_number(k, U10);
    const double Theta_k_wv = Theta_k / k;

    return Theta_k_wv;    
}

static double directional_mitsuyasu(double omega_p, double omega, double theta_p, double theta)
{
    const double s_p = (omega >= omega_p) ? 9.77 : 6.97;
    const double omega_div_omega_p = (omega >= omega_p) ? pow(omega / omega_p, -2.5) : pow(omega / omega_p, 5.0);
    const double s = s_p * omega_div_omega_p;

    printf("%f %f\n",s, fabs(cos((theta - theta_p) * 0.5)));

    const double numerator = tgamma(s + 1.0);
    const double numeratorSquare = numerator * numerator;
    const double denominator = tgamma(2.0 * s + 1.0);

    const double term_one = pow(2.0, 2.0 * s - 1.0) / M_PI;
    const double term_two = numeratorSquare / denominator;
    const double term_three = pow(fabs(cos((theta - theta_p) * 0.5)), 2.0 * s);

    printf("1:%f 2:%f 3:%f\n", term_one, term_two, term_three);

    return term_one * term_two * term_three;
}

int main (int argc, char **argv)
{
    feenableexcept(FE_DIVBYZERO | FE_INVALID);

    /*
    for (double o = 0.0; o <= 2.0 * M_PI; o += 0.5)
    {
        printf("%f %f\n", o, energy_pm_wave_frequency(o, 10.0));
    }
    */

    /*
    for (double o = 0.0; o <= 2.0 * M_PI; o += 0.5)
    {
        double k = (o * o) / 9.81;
        printf("%f %f\n", o, energy_pm_wave_number(k, 10.0));
    }
    */

    const int32_t resolution = 4;
    const double area = 100.0;
    const double U10 = 100.0;

    const double deltakx = 2.0 * M_PI / area;
    const double deltaky = 2.0 * M_PI / area;

    for (int32_t alpha = -resolution/2; alpha < resolution/2; alpha++)
    {
        for (int32_t beta = resolution/2; beta > -resolution/2; beta--)
        {
            double kx = alpha * deltakx;
            double ky = beta  * deltaky;
            double k  = sqrtf(kx*kx + ky*ky);

            //printf("%d %d %f %f %f\n", alpha, beta, kx , ky, k);

            double omega = sqrtf(k * 9.81f);
            double Theta = energy_pm_wave_frequency(omega, U10);

//            printf("%f %f\n", omega, Theta);

            double theta = atan2(ky, kx);

            double dir = directional_mitsuyasu(0.083876, omega, 0.0, theta);

            //printf("%f %f\n", omega, theta);
        }
    }

    return EXIT_SUCCESS;
}

