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
    generateFloatSpectrumWithGeometry:(OdSpectrumGeometry)geometry
                            generator:(OdGeneratorSettings)generatorSettings
                               atTime:(float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
{
    return
        [ floatGenerator
            generateFloatSpectrumWithGeometry:geometry
                                    generator:generatorSettings
                                       atTime:time
                         generateBaseGeometry:generateBaseGeometry ];
}

@end

