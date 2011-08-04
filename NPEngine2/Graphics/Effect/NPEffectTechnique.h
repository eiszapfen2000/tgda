#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@class NPShader;
@class NPEffect;

@interface NPEffectTechnique : NPObject
{
    GLuint glID;

    NPShader * vertexShader;
    NPShader * fragmentShader;

    NPEffect * effect;
    NSMutableArray * techniqueVariables;
}

- (id) initWithName:(NSString *)newName
             effect:(NPEffect *)newEffect
                   ;
- (void) dealloc;
- (void) clear;

- (GLuint) glID;
- (NPShader *) vertexShader;
- (NPShader *) fragmentShader;
- (NPEffect *) effect;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

- (void) activate;
- (void) activate:(BOOL)force;

@end

