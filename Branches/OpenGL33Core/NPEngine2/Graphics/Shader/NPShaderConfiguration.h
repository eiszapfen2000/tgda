#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NPShader;
@class NSMutableArray;

@interface NPShaderConfiguration : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    GLuint glID;
    NPShader * vertexShader;
    NPShader * fragmentShader;
    NSMutableArray * shaderVariables;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

@end

