#import "ODPFrequencySpectrumGeneration.h"

bool geometries_equal(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->numberOfLods != gTwo->numberOfLods
         || gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return false;
    }

    for (uint32_t i = 0; i < gOne->numberOfLods; i++ )
    {
        if ( gOne->sizes[i].x != gTwo->sizes[i].x 
             || gOne->sizes[i].y != gTwo->sizes[i].y )
        {
            return false;
        }
    }

    return true;
}

bool geometries_equal_size(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->numberOfLods != gTwo->numberOfLods )
    {
        return false;
    }

    for (uint32_t i = 0; i < gOne->numberOfLods; i++ )
    {
        if ( gOne->sizes[i].x != gTwo->sizes[i].x 
             || gOne->sizes[i].y != gTwo->sizes[i].y )
        {
            return false;
        }
    }

    return true;
}

bool geometries_equal_resolution(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo)
{
    if ( gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return false;
    }

    return true;
}

bool phillips_settings_equal(const ODPhillipsGeneratorSettings * pOne, const ODPhillipsGeneratorSettings * pTwo)
{
    if ( pOne->windSpeed != pTwo->windSpeed
         || pOne->dampening != pTwo->dampening
         || pOne->windDirection.x != pTwo->windDirection.x
         || pOne->windDirection.y != pTwo->windDirection.y )
    {
        return false;
    }

    return true;
}

bool unified_settings_equal(const ODUnifiedGeneratorSettings * pOne, const ODUnifiedGeneratorSettings * pTwo)
{
    if ( pOne->U10 != pTwo->U10
         || pOne->Omega != pTwo->Omega )
    {
        return false;
    }

    return true;
}

bool generator_settings_equal(const ODGeneratorSettings * pOne, const ODGeneratorSettings * pTwo)
{
    if ( pOne->generatorType != pTwo->generatorType
         || pOne->spectrumScale != pTwo->spectrumScale )
    {
        return false;
    }

    switch ( pOne->generatorType )
    {
        case Phillips:
            return phillips_settings_equal(&(pOne->phillips), &(pTwo->phillips));
        case Unified:
            return unified_settings_equal(&(pOne->unified), &(pTwo->unified));
        default:
            return false;
    }
}

