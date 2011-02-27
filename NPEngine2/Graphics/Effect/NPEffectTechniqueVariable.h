#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@interface NPEffectTechniqueVariable : NPObject
{
    id effectVariable;
    GLint location;
}

- (id) initWithName:(NSString *)newName
     effectVariable:(id)newEffectVariable
           location:(GLint)newLocation
                   ;

- (GLint) location;

- (void) activate;

@end
