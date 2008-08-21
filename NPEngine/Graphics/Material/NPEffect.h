#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"
#import "Core/Math/FVector.h"
#import "Core/Math/FMatrix.h"

#import "Cg/cg.h"
#import "Cg/cgGL.h"

#define NP_GRAPHICS_MATERIAL_MODEL_MATRIX_SEMANTIC                  @"NPMODEL"
#define NP_GRAPHICS_MATERIAL_VIEW_MATRIX_SEMANTIC                   @"NPVIEW"
#define NP_GRAPHICS_MATERIAL_PROJECTION_MATRIX_SEMANTIC             @"NPPROJECTION"
#define NP_GRAPHICS_MATERIAL_MODELVIEWPROJECTION_MATRIX_SEMANTIC    @"NPMODELVIEWPROJECTION"
#define NP_GRAPHICS_MATERIAL_COLORMAP_BASE_SEMANTIC                 @"NPCOLORMAP"
#define NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(_index)              [ NP_GRAPHICS_MATERIAL_COLORMAP_BASE_SEMANTIC stringByAppendingFormat:@"%d",_index ]

typedef struct
{
    CGparameter modelMatrix;
    CGparameter viewMatrix;
    CGparameter projectionMatrix;
    CGparameter modelViewProjectionMatrix;
    CGparameter sampler[8];
}
NpDefaultSemantics;

@interface NPEffect : NPResource
{
    CGeffect effect;
    CGtechnique defaultTechnique;
    //NPEffectTechnique * defaultTechnqiue;
    NpDefaultSemantics defaultSemantics;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;

- (CGeffect) effect;
- (CGtechnique) defaultTechnique;
- (void) setDefaultTechnique:(CGtechnique)newDefaultTechnique;

- (NpDefaultSemantics *) defaultSemantics;
- (void) clearDefaultSemantics;
- (CGparameter) bindDefaultSemantic:(NSString *)semanticName;
- (void) bindDefaultSemantics;

- (void) activate;

- (void) uploadDefaultSemantics;

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f;
- (void) upLoadFloatParameter:(CGparameter)parameter andValue:(Float *)f;
- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32 *)i;
- (void) upLoadIntParameter:(CGparameter)parameter andValue:(Int32 *)i;

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

@end
