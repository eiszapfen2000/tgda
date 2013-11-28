#import "ODPFrequencySpectrumGeneration.h"

BOOL geometries_equal(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->size.x != gTwo->size.x
         || gOne->size.y != gTwo->size.y
         || gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return NO;
    }

    return YES;
}

BOOL geometries_equal_size(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->size.x != gTwo->size.x
         || gOne->size.y != gTwo->size.y )
    {
        return NO;
    }

    return YES;
}

BOOL geometries_equal_resolution(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return NO;
    }

    return YES;
}

BOOL phillips_settings_equal(const ODPhillipsGeneratorSettings * pOne, const ODPhillipsGeneratorSettings * pTwo)
{
    if ( pOne->windSpeed != pTwo->windSpeed
         || pOne->dampening != pTwo->dampening
         || pOne->windDirection.x != pTwo->windDirection.x
         || pOne->windDirection.y != pTwo->windDirection.y )
    {
        return NO;
    }

    return YES;
}

BOOL unified_settings_equal(const ODUnifiedGeneratorSettings * pOne, const ODUnifiedGeneratorSettings * pTwo)
{
    if ( pOne->U10 != pTwo->U10
         || pOne->Omega != pTwo->Omega )
    {
        return NO;
    }

    return YES;
}

BOOL generator_settings_equal(const ODGeneratorSettings * pOne, const ODGeneratorSettings * pTwo)
{
    if ( pOne->generatorType != pTwo->generatorType )
    {
        return NO;
    }

    switch ( pOne->generatorType )
    {
        case Phillips:
            return phillips_settings_equal(&(pOne->phillips), &(pTwo->phillips));
        case Unified:
            return unified_settings_equal(&(pOne->unified), &(pTwo->unified));
        default:
            return NO;
    }
}

