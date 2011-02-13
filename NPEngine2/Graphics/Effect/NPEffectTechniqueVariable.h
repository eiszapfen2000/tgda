#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@interface NPEffectTechniqueVariable : NPObject
{
    GLint location;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
                   ;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
           location:(GLint)newLocation
                   ;

- (GLint) location;

@end
