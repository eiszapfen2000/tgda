#import "Core/NPObject/NPObject.h"

@class NPShader;

@interface NPEffectTechnique : NPObject
{
    NPShader * vertexShader;
    NPShader * fragmentShader;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) addVertexShaderFromFile:(NSString *)fileName;
- (void) addFragmentShaderFromFile:(NSString *)fileName;

@end

