#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPEffect;

#define ATTRACTOR_LORENTZ   0
#define ATTRACTOR_ROESSLER  1

@interface FAttractor : NPObject
{
    NpState mode;
    NPEffect * effect;
    NPVertexBuffer * coordinateCross;
    NPVertexBuffer * lorentzAttractor;
    NPVertexBuffer * roesslerAttractor;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;
- (void) reset;

- (NpState) mode;
- (void) setMode:(NpState)newMode;

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

- (void) generateAttractorOfType:(NpState)Type
                 withParametersA:(Float)a
                               B:(Float)b
                               C:(Float)c
                               R:(Float)r
                           Sigma:(Float)sigma
              numberOfIterations:(UInt32)numberOfIterations
                   startingPoint:(FVector3)startingPoint
                                ;

- (void) update:(Float)frameTime;
- (void) render;

@end
