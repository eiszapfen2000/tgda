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

typedef struct
{
    Int resX, resY;
    Int length, width;
    Vector2 wind;
}
ToOceanSurface;

@class NPRandomNumberGenerator;
@class NPGaussianRandomNumberGenerator;
@class TOFrequencySpectrumGenerator;

@interface TOOceanSurfaceGenerator : NPObject
{
    IVector2 resolution;
    Vector2 size;
    Vector2 wind;

    Int numberOfThreads;

    NSMutableDictionary * firstRNGs;
    NSMutableDictionary * secondRNGs;
	NPGaussianRandomNumberGenerator * gaussianRNG;

    NSMutableDictionary * frequencySpectrumGenerators;
    NSString * currentFSGTypeName;

    BOOL resOK;
    BOOL sizeOK;
    BOOL rngOK;
    BOOL threadsOK;

    Double * heights;

    //Vector3 * pointArray;

    //long * pointIndexArray;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (BOOL) ready;

- (void) createRNGsForDictionary:(NSMutableDictionary *)dictionary;
- (void) createFSGsForDictionary:(NSMutableDictionary *)dictionary;

- (void) setResX:(Int)newResX;
- (void) setResY:(Int)newResY;
- (void) setLength:(Double)newLength;
- (void) setWidth:(Double)newWidth;

- (void) setCurrentFSGTypeName:(NSString *)newCurrentFSGTypeName;

- (void) setWindX:(Double)newWindX;
- (void) setWindY:(Double)newWindY;
- (void) setNumberOfThreads:(Int)newNumberOfThreads;

- (void) generateHeightfield;

- (void) buildVertexArrayUsingFSG:(TOFrequencySpectrumGenerator *)fsg;

@end

