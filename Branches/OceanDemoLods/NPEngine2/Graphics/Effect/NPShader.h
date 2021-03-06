#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@interface NPShader : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NpShaderType shaderType;
    GLuint glID;
}

+ (id) shaderFromStringList:(NPStringList *)source
                      error:(NSError **)error
                           ;

+ (id) shaderFromStream:(id <NPPStream>)stream
                  error:(NSError **)error
                       ;

+ (id) shaderFromFile:(NSString *)fileName
                error:(NSError **)error
                     ;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;

- (GLuint) glID;
- (NpShaderType) shaderType;

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
                           ;

@end

