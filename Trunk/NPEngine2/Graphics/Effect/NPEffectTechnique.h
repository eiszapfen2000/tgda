#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@class NPShader;
@class NPEffect;
@class NPEffectTechniqueVariable;
@class NSMutableArray;
@class NPStringList;

@interface NPEffectTechnique : NPObject
{
    GLuint glID;

    NPShader * vertexShader;
    NPShader * geometryShader;
    NPShader * fragmentShader;

    NPEffect * effect;
    NSMutableArray * techniqueVariables;
}

+ (BOOL) checkProgramLinkStatus:(GLuint)glID
                          error:(NSError **)error
                               ;

+ (void) activate;
+ (void) deactivate;

- (id) initWithName:(NSString *)newName
             effect:(NPEffect *)newEffect
                   ;
- (void) dealloc;
- (void) clear;

- (void) lock;
- (void) unlock;

- (GLuint) glID;
- (NPShader *) vertexShader;
- (NPShader *) fragmentShader;
- (NPEffect *) effect;
- (NPEffectTechniqueVariable *) techniqueVariableWithName:(NSString *)variableName;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

- (void) activate;
- (void) activate:(BOOL)force;

@end

