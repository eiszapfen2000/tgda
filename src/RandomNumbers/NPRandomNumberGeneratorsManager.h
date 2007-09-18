#import <Foundation/Foundation.h>

#import "NPPRandomNumberGeneration.h"
#import "NPRandomNumberGenerators.h"
#import "NPGaussianRandomNumberGenerator.h"

@interface NPRandomNumberGeneratorsManager : NSObject
{
	NSSet * fixedParameterGeneratorNames;

	NSMutableArray * generators;
}

- init;

- (NPGaussianRandomNumberGenerator *) gaussianGenerator;

- (NPRandomNumberGenerator *) fixedParameterGeneratorWithString: (NSString *) name;

- (NPRandomNumberGenerator *) mersenneTwisterWithSeed: (ULong) seed;

- (NPRandomNumberGenerator *) lcgGenerator;
- (NPRandomNumberGenerator *) lcgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    ;


- (NPRandomNumberGenerator *) icgGenerator;
- (NPRandomNumberGenerator *) icgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    ;

- (NPRandomNumberGenerator *) eicgGenerator;
- (NPRandomNumberGenerator *) eicgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    ;

- (NPRandomNumberGenerator *) meicgGenerator;
- (NPRandomNumberGenerator *) meicgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    ;

- (NPRandomNumberGenerator *) dicgGenerator;
- (NPRandomNumberGenerator *) dicgGeneratorWithParameters
    : (ULong) periodExponent
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    ;

- (NPRandomNumberGenerator *) qcgGenerator;
- (NPRandomNumberGenerator *) qcgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    : (ULong) c
    ;

- (void) dealloc;

@end
