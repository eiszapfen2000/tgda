#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@class NPShader;

@interface NPEffectTechnique : NPObject
{
    GLuint glID;

    NPShader * vertexShader;
    NPShader * fragmentShader;

    NSMutableArray * techniqueVariables;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;
- (void) dealloc;

- (void) clear;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

@end

