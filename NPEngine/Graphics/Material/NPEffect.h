#import "Core/NPObject/NPObject.h"
#import "Core/File/NPFile.h"
#import "Core/Resource/NPResource.h"
#import "Core/Math/FVector.h"
#import "Core/Math/FMatrix.h"

#import "Cg/cg.h"
#import "Cg/cgGL.h"

@interface NPEffect : NPResource < NPPResource >
{
    CGeffect effect;

    CGtechnique defaultTechnique;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

- (void) uploadFloatParameterWithName:(NSString *)parameterName andValue:(Float *)f;
- (void) uploadIntParameterWithName:(NSString *)parameterName andValue:(Int32 *)i;

- (void) uploadFVector2ParameterWithName:(NSString *)parameterName andValue:(FVector2 *)vector;
- (void) uploadFVector3ParameterWithName:(NSString *)parameterName andValue:(FVector3 *)vector;
- (void) uploadFVector4ParameterWithName:(NSString *)parameterName andValue:(FVector4 *)vector;

- (void) uploadFMatrix2ParameterWithName:(NSString *)parameterName andValue:(FMatrix2 *)matrix;
- (void) uploadFMatrix3ParameterWithName:(NSString *)parameterName andValue:(FMatrix3 *)matrix;
- (void) uploadFMatrix4ParameterWithName:(NSString *)parameterName andValue:(FMatrix4 *)matrix;

@end
