#define _GNU_SOURCE
#import <assert.h>
#import <fenv.h>
#import <math.h>
#import <stdio.h>
#import <stdlib.h>
#import <time.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/NSThread.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/Utilities/NSData+NPEngine.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"

#define MATH_g 9.81

static double energy_pm_omega_p(double U10)
{
    const double g = 9.81;
    const double omega_p = (0.855 * g / U10);

    return omega_p;
}

static double energy_pm_wave_frequency(double omega, double U10)
{
    if (omega == 0.0)
    {
        return 0.0;
    }

    const double g = MATH_g;
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

    const double g = MATH_g;
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

    //printf("%f %f\n",s, fabs(cos((theta - theta_p) * 0.5)));

    const double numerator = tgamma(s + 1.0);
    const double numeratorSquare = numerator * numerator;
    const double denominator = tgamma(2.0 * s + 1.0);

    const double term_one = pow(2.0, 2.0 * s - 1.0) / M_PI;
    const double term_two = numeratorSquare / denominator;
    const double term_three = pow(fabs(cos((theta - theta_p) * 0.5)), 2.0 * s);

    //printf("1:%f 2:%f 3:%f\n", term_one, term_two, term_three);

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
    const double area = 10.0;
    const double U10 = 10.0;
    const double omega_p = energy_pm_omega_p(U10);

    const double deltakx = 2.0 * M_PI / area;
    const double deltaky = 2.0 * M_PI / area;

    double mss_x = 0.0;
    double mss_z = 0.0;
    double mss = 0.0;

    for (int32_t alpha = -resolution/2; alpha < resolution/2; alpha++)
    {
        for (int32_t beta = resolution/2; beta > -resolution/2; beta--)
        {
            double kx = alpha * deltakx;
            double ky = beta  * deltaky;
            double k  = sqrtf(kx*kx + ky*ky);

            //printf("%d %d %f %f %f\n", alpha, beta, kx , ky, k);

            double omega = sqrtf(k * MATH_g);
            double Theta = energy_pm_wave_frequency(omega, U10);

            Vector2 k_wv = {.x = kx, .y = ky};
            double Theta_k_wv = energy_pm_wave_vector(k_wv, U10);

            //printf("%f %f\n", omega, Theta_k_wv);

            double theta = atan2(ky, kx);

            double dir = directional_mitsuyasu(omega_p, omega, 0.0, theta);
            double amplitude = sqrt(2.0 * Theta_k_wv * dir * deltakx * deltaky);

            mss_x += kx*kx*Theta_k_wv*dir*deltakx*deltakx;
            mss_z += ky*ky*Theta_k_wv*dir*deltaky*deltaky;
            mss += (kx*kx+ky*ky)*Theta_k_wv*dir*deltakx*deltaky;

            printf("%f\n", amplitude);
        }
    }

    printf("%f %f %f\n", mss_x, mss_z, mss);

    return EXIT_SUCCESS;
}

