#import "Core/NPEngineCore.h"
#import "Core/Timer/NPTimer.h"
#import "ODPhillipsSpectrumFloat.h"
#import "ODPhillipsSpectrum.h"

@implementation ODPhillipsSpectrum

- (id) init
{
    return [ self initWithName:@"Phillips Spectrum" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    floatGenerator  = [[ ODPhillipsSpectrumFloat  alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(floatGenerator);

    [ super dealloc ];
}

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumWithGeometry:(ODSpectrumGeometry)geometry
                            generator:(ODGeneratorSettings)generatorSettings
                               atTime:(const float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
{
    return
        [ floatGenerator
            generateFloatSpectrumWithGeometry:geometry
                                    generator:generatorSettings
                                       atTime:time
                         generateBaseGeometry:generateBaseGeometry ];
}

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumHCWithGeometry:(ODSpectrumGeometry)geometry
                              generator:(ODGeneratorSettings)generatorSettings
                                 atTime:(const float)time
                   generateBaseGeometry:(BOOL)generateBaseGeometry
{
    return
        [ floatGenerator
            generateFloatSpectrumHCWithGeometry:geometry
                                      generator:generatorSettings
                                         atTime:time
                           generateBaseGeometry:generateBaseGeometry ];
}

@end

