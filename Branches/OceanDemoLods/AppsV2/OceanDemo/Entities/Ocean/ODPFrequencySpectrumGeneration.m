#import "ODPFrequencySpectrumGeneration.h"

void geometry_init_with_resolutions_and_lods(OdSpectrumGeometry * geometry,
    int32_t geometryRes, int32_t gradientRes, uint32_t numberOfLods)
{
    assert(geometry != NULL && geometry->sizes == NULL);

    geometry->geometryResolution = (IVector2){geometryRes, geometryRes};
    geometry->gradientResolution = (IVector2){gradientRes, gradientRes};
    geometry->numberOfLods = numberOfLods;
    geometry->sizes = ALLOC_ARRAY(Vector2, numberOfLods);
}

void geometry_set_max_size(OdSpectrumGeometry * geometry, double maxSize)
{
    assert(geometry != NULL && geometry->sizes != NULL);

    geometry->sizes[0] = (Vector2){maxSize, maxSize};
}

void geometry_set_size(OdSpectrumGeometry * geometry,
    uint32_t lodIndex, double lodSize)
{
    assert(geometry != NULL && geometry->sizes != NULL);

    if ( lodIndex < geometry->numberOfLods )
    {
        geometry->sizes[lodIndex] = (Vector2){lodSize, lodSize};
    }
}

void geometry_clear(OdSpectrumGeometry * geometry)
{
    if ( geometry != NULL )
    {
        SAFE_FREE(geometry->sizes);
    }
}

void geometry_copy(const OdSpectrumGeometry * source, OdSpectrumGeometry * target)
{
    assert(source != NULL || target != NULL );

    SAFE_FREE(target->sizes);

    target->geometryResolution = source->geometryResolution;
    target->gradientResolution = source->gradientResolution;
    target->numberOfLods = source->numberOfLods;

    if ( source->numberOfLods != 0 )
    {
        target->sizes = ALLOC_ARRAY(Vector2, source->numberOfLods);
        memcpy(target->sizes, source->sizes, sizeof(Vector2) * source->numberOfLods);
    }
}

bool geometries_equal(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo)
{
    assert(gOne != NULL && gTwo != NULL);

    if ( gOne->numberOfLods != gTwo->numberOfLods
         || gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return false;
    }

    for ( uint32_t i = 0; i < gOne->numberOfLods; i++ )
    {
        if ( gOne->sizes[i].x != gTwo->sizes[i].x 
             || gOne->sizes[i].y != gTwo->sizes[i].y )
        {
            return false;
        }
    }

    return true;
}

bool geometries_equal_size(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo)
{
    assert(gOne != NULL && gTwo != NULL && gOne->sizes != NULL && gTwo->sizes != NULL);

    if ( gOne->numberOfLods != gTwo->numberOfLods )
    {
        return false;
    }

    for ( uint32_t i = 0; i < gOne->numberOfLods; i++ )
    {
        if ( gOne->sizes[i].x != gTwo->sizes[i].x 
             || gOne->sizes[i].y != gTwo->sizes[i].y )
        {
            return false;
        }
    }

    return true;
}

bool geometries_equal_resolution(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo)
{
    assert(gOne != NULL && gTwo != NULL);

    if ( gOne->geometryResolution.x != gTwo->geometryResolution.x
         || gOne->geometryResolution.y != gTwo->geometryResolution.y
         || gOne->gradientResolution.x != gTwo->gradientResolution.x
         || gOne->gradientResolution.y != gTwo->gradientResolution.y )
    {
        return false;
    }

    return true;
}

OdSpectrumGeometry geometry_zero()
{
    OdSpectrumGeometry result;

    result.geometryResolution = iv2_zero();
    result.gradientResolution = iv2_zero();
    result.numberOfLods = 0;
    result.sizes = NULL;

    return result;
}

OdSpectrumGeometry geometry_max()
{
    OdSpectrumGeometry result;

    result.geometryResolution = iv2_max();
    result.gradientResolution = iv2_max();
    result.numberOfLods = UINT32_MAX;
    result.sizes = NULL;

    return result;
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

ODGeneratorSettings generator_settings_zero()
{
    ODGeneratorSettings result;

    result.generatorType = Unknown;
    result.spectrumScale = 0.0;
    result.phillips.windDirection = v2_zero();
    result.phillips.windSpeed = 0.0;
    result.phillips.dampening = 0.0;
    result.unified.U10   = 0.0;
    result.unified.Omega = 0.0;

    return result;
}

ODGeneratorSettings generator_settings_max()
{
    ODGeneratorSettings result;

    result.generatorType = Unknown;
    result.spectrumScale = DBL_MAX;
    result.phillips.windDirection = v2_max();
    result.phillips.windSpeed = DBL_MAX;
    result.phillips.dampening = DBL_MAX;
    result.unified.U10   = DBL_MAX;
    result.unified.Omega = DBL_MAX;

    return result;
}


