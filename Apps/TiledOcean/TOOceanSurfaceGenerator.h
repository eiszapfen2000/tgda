#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

#import "fftw3.h"

typedef enum
{
    ToPhillipsSpectrum = 1,
    ToSWOPSpectrum = 2,
    ToPiersmosSpectrum = 3,
    ToJONSWAPSpectrum = 4    
}
ToSpectrum;

@class NPRandomNumberGenerator;
@class NPGaussianRandomNumberGenerator;


@interface TOOceanSurfaceGenerator : NPObject
{
    Int resX, resY;
    Int length, width;
    Vector2 wind;

    NSMutableDictionary * firstRNGs;
    NSMutableDictionary * secondRNGs;
	NPGaussianRandomNumberGenerator * gaussianRNG;

    NSMutableDictionary * frequencySpectrumGenerators;

    BOOL ready;

    Double * heights;

    //Vector3 * pointArray;

    //long * pointIndexArray;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (void) createRNGsForDictionary:(NSMutableDictionary *)dictionary;
- (void) createFSGsForDictionary:(NSMutableDictionary *)dictionary;

- (Int) resX;
- (void) setResX:(Int)newResX;
- (Int) resY;
- (void) setResY:(Int)newResY;
- (Int) length;
- (void) setLength:(Int)newLength;
- (Int) width;
- (void) setWidth:(Int)newWidth;

- (void) setWindX:(Double)newWindX;
- (void) setWindY:(Double)newWindY;

- (void) generateHeightfield;

@end

