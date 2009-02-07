#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPEffectTechnique;

typedef struct NpDefaultSemantics
{
    CGparameter modelMatrix;
    CGparameter inverseModelMatrix;
    CGparameter viewMatrix;
    CGparameter inverseViewMatrix;
    CGparameter projectionMatrix;
    CGparameter inverseProjectionMatrix;
    CGparameter modelViewMatrix;
    CGparameter inverseModelViewMatrix;
    CGparameter viewProjectionMatrix;
    CGparameter inverseViewProjectionMatrix;
    CGparameter modelViewProjectionMatrix;
    CGparameter inverseModelViewProjectionMatrix;
    CGparameter sampler1D[8];
    CGparameter sampler2D[8];
    CGparameter sampler3D[8];
}
NpDefaultSemantics;

@interface NPEffect : NPResource
{
    CGeffect effect;
    NPEffectTechnique * defaultTechnique;
    NSMutableDictionary * techniques;
    NpDefaultSemantics defaultSemantics;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;

- (NpDefaultSemantics *) defaultSemantics;
- (NPEffectTechnique *) defaultTechnique;
- (NPEffectTechnique *) techniqueWithName:(NSString *)techniqueName;

- (void) setDefaultTechnique:(NPEffectTechnique *)newDefaultTechnique;

- (void) clearDefaultSemantics;
- (CGparameter) bindDefaultSemantic:(NSString *)semanticName;
- (void) bindDefaultSemantics;

- (void) activate;

- (void) uploadDefaultSemantics;

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float)f;
- (void) upLoadFloatParameter:(CGparameter)parameter andValue:(Float)f;
- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32)i;
- (void) upLoadIntParameter:(CGparameter)parameter andValue:(Int32)i;

- (void) uploadFVector2ParameterWithName:(NSString *)parameterName andValue:(FVector2 *)vector;
- (void) uploadFVector2Parameter:(CGparameter)parameter andValue:(FVector2 *)vector;
- (void) uploadFVector3ParameterWithName:(NSString *)parameterName andValue:(FVector3 *)vector;
- (void) uploadFVector3Parameter:(CGparameter)parameter andValue:(FVector3 *)vector;
- (void) uploadFVector4ParameterWithName:(NSString *)parameterName andValue:(FVector4 *)vector;
- (void) uploadFVector4Parameter:(CGparameter)parameter andValue:(FVector4 *)vector;

- (void) uploadFMatrix2ParameterWithName:(NSString *)parameterName andValue:(FMatrix2 *)matrix;
- (void) uploadFMatrix2Parameter:(CGparameter)parameter andValue:(FMatrix2 *)matrix;
- (void) uploadFMatrix3ParameterWithName:(NSString *)parameterName andValue:(FMatrix3 *)matrix;
- (void) uploadFMatrix3Parameter:(CGparameter)parameter andValue:(FMatrix3 *)matrix;
- (void) uploadFMatrix4ParameterWithName:(NSString *)parameterName andValue:(FMatrix4 *)matrix;
- (void) uploadFMatrix4Parameter:(CGparameter)parameter andValue:(FMatrix4 *)matrix;

- (void) uploadSampler2DWithParameterName:(NSString *)parameterName andID:(GLuint)textureID;
- (void) uploadSampler2DWithParameter:(CGparameter)parameter andID:(GLuint)textureID;
- (void) uploadSampler3DWithParameterName:(NSString *)parameterName andID:(GLuint)textureID;
- (void) uploadSampler3DWithParameter:(CGparameter)parameter andID:(GLuint)textureID;

@end
