#import "Core/Basics/NpBasics.h"
#import "Core/NPObject/NPObject.h"

@class NPGaussianRandomNumberGenerator;
@class NPRandomNumberGenerator;

@interface NPRandomNumberGeneratorManager : NPObject
{
	NSSet * fixedParameterGeneratorNames;

	NSMutableArray * generators;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPGaussianRandomNumberGenerator *) gaussianGenerator;

- (NPRandomNumberGenerator *) fixedParameterGeneratorWithRNGName:(NSString *)rngName;

- (NPRandomNumberGenerator *) mersenneTwisterWithSeed:(ULong)seed;

- (NPRandomNumberGenerator *) lcgGenerator;
- (NPRandomNumberGenerator *) lcgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    ;


- (NPRandomNumberGenerator *) icgGenerator;
- (NPRandomNumberGenerator *) icgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    ;

- (NPRandomNumberGenerator *) eicgGenerator;
- (NPRandomNumberGenerator *) eicgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    ;

- (NPRandomNumberGenerator *) meicgGenerator;
- (NPRandomNumberGenerator *) meicgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    ;

- (NPRandomNumberGenerator *) dicgGenerator;
- (NPRandomNumberGenerator *) dicgGeneratorWithParameters
    :(ULong)periodExponent
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    ;

- (NPRandomNumberGenerator *) qcgGenerator;
- (NPRandomNumberGenerator *) qcgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    :(ULong)c
    ;

@end
