#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@interface NPShader : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NpShaderType shaderType;
    GLuint glID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

- (GLuint) glID;
- (NpShaderType) shaderType;

@end

