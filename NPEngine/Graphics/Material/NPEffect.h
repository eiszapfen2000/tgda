#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"
#import "Core/Math/FVector.h"
#import "Core/Math/FMatrix.h"

#import "Cg/cg.h"
#import "Cg/cgGL.h"

typedef struct
{
    CGparameter modelMatrix;
    CGparameter viewMatrix;
    CGparameter projectionMatrix;
    CGparameter modelViewProjectionMatrix;
    CGparameter sampler[8];
}
NpDefaultSemantics;

@interface NPEffect : NPResource < NPPResource >
{
    CGeffect effect;
    CGtechnique defaultTechnique;
    NpDefaultSemantics defaultSemantics;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

- (CGeffect) effect;
- (CGtechnique) defaultTechnique;
- (void) setDefaultTechnique:(CGtechnique)newDefaultTechnique;

- (NpDefaultSemantics *) defaultSemantics;
- (void) clearDefaultSemantics;
- (CGparameter) bindDefaultSemantic:(NSString *)semanticName;
- (void) bindDefaultSemantics;

- (void) activate;

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f;
- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32 *)i;

- (void) uploadFVector2ParameterWithName:(NSString *)parameterName andValue:(FVector2 *)vector;
- (void) uploadFVector3ParameterWithName:(NSString *)parameterName andValue:(FVector3 *)vector;
- (void) uploadFVector4ParameterWithName:(NSString *)parameterName andValue:(FVector4 *)vector;

- (void) uploadFMatrix2ParameterWithName:(NSString *)parameterName andValue:(FMatrix2 *)matrix;
- (void) uploadFMatrix3ParameterWithName:(NSString *)parameterName andValue:(FMatrix3 *)matrix;
- (void) uploadFMatrix4ParameterWithName:(NSString *)parameterName andValue:(FMatrix4 *)matrix;

- (void) uploadSampler2DWithParameter:(CGparameter)parameter andID:(GLuint)textureID;

@end
