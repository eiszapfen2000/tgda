#import "Core/NPEngineCore.h"
#import "Core/Timer/NPTimer.h"
#import "ODFrequencySpectrumFloat.h"
#import "ODFrequencySpectrum.h"

@implementation ODFrequencySpectrum

- (id) init
{
    return [ self initWithName:@"Frequency Spectrum" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    floatGenerator  = [[ ODFrequencySpectrumFloat  alloc ] init ];

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

