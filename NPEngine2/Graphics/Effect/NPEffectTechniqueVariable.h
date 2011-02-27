#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@interface NPEffectTechniqueVariable : NPObject
{
    GLint location;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           location:(GLint)newLocation
                   ;

- (GLint) location;

- (void) activate;

@end
