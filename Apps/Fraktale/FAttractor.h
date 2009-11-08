#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPEffect;

@interface FAttractor : NPObject
{
    FVector3 * startingPoint;

    NPEffect * effect;
    NPVertexBuffer * coordinateCross;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;
- (void) reset;

- (void) setupCoordinateCross;


- (FVector3) generateLorentzDerivativeWithParametersSigma:(Float)sigma
                                                        B:(Float)b
                                                        R:(Float)r
                                             currentPoint:(FVector3)currentPoint
                                                         ;

- (void) generateLorentzAttractorWithParametersSigma:(Float)sigma
                                                   B:(Float)b
                                                   R:(Float)r
                                  numberOfIterations:(UInt32)numberOfIterations
                                       startingPoint:(FVector3)startingPoint
                                                    ;

- (FVector3) generateRoesslerDerivativeWithParametersA:(Float)a
                                                     B:(Float)b
                                                     C:(Float)c
                                          currentPoint:(FVector3)currentPoint
                                                      ;

- (void) generateRoesslerAttractorWithParametersA:(Float)a
                                                B:(Float)b
                                                C:(Float)c
                               numberOfIterations:(UInt32)numberOfIterations
                                    startingPoint:(FVector3)startingPoint
                                                 ;

- (void) update:(Float)frameTime;
- (void) render;

@end
