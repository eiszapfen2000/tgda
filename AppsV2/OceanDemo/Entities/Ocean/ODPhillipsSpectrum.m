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
    doubleGenerator = [[ ODPhillipsSpectrumDouble alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(doubleGenerator);
    DESTROY(floatGenerator);

    [ super dealloc ];
}

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrum:(const ODSpectrumSettings)settings
                                                       atTime:(const double)time
{
    return [ doubleGenerator generateDoubleFrequencySpectrum:settings atTime:time ];
}

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                                         atTime:(const double)time
{
    return [ doubleGenerator generateDoubleFrequencySpectrumHC:settings atTime:time ];
}

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                                     atTime:(const float)time
{
    return [ floatGenerator generateFloatFrequencySpectrum:settings atTime:time ];
}

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                                       atTime:(const float)time
{
    return [ floatGenerator generateFloatFrequencySpectrumHC:settings atTime:time ];
}

@end

