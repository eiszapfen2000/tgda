#import "Core/NPEngineCore.h"
#import "Core/Timer/NPTimer.h"
#import "ODPhillipsSpectrumFloat.h"
#import "ODPhillipsSpectrumDouble.h"
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

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const float)time
                              generateBaseGeometry:(BOOL)generateBaseGeometry
{
    return
        [ floatGenerator
            generateFloatFrequencySpectrum:settings
                                    atTime:time
                      generateBaseGeometry:generateBaseGeometry ];
}

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const float)time
                                generateBaseGeometry:(BOOL)generateBaseGeometry
{
    return
        [ floatGenerator
            generateFloatFrequencySpectrumHC:settings
                                      atTime:time
                        generateBaseGeometry:generateBaseGeometry ];
}

@end

