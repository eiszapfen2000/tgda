#import "Log/NPLog.h"
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPShader.h"

@interface NPShader (Private)

+ (NpShaderType) shaderTypeFromFileName:(NSString *)fileName;
+ (GLenum) glShaderTypeFromNpShaderType:(NpShaderType)shaderType;
+ (BOOL) checkShaderCompileStatus:(GLuint)glID
                            error:(NSError **)error
                                 ;

@end

@implementation NPShader

- (id) init
{
    return [ self initWithName:@"Shader" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    file = nil;
    ready = NO;

    glID = 0;
    shaderType = NpShaderTypeUnknown;

    [[[ NPEngineGraphics instance ] shader ] registerAsset:self ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineGraphics instance ] shader ] unregisterAsset:self ];

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (GLuint) glID
{
    return glID;
}

- (NpShaderType) shaderType
{
    return shaderType;
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;

   	if (glID > 0)
	{
		glDeleteShader(glID);
	}

    shaderType = NpShaderTypeUnknown;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    [ self clear ];

    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"Loading shader \"%@\"", completeFileName);

    // try to load text file
    NSStringEncoding encoding;
    NSString * shaderSource
        = [ NSString stringWithContentsOfFile:completeFileName
                                 usedEncoding:&encoding
                                        error:error ];

    if ( shaderSource == nil )
    {
        return NO;
    }

    // determine shader type from file extensions
    shaderType = [ NPShader shaderTypeFromFileName:completeFileName ];
    if ( shaderType == NpShaderTypeUnknown )
    {
        return NO;
    }

    // determine GL shader type
    GLenum glShaderType = [ NPShader glShaderTypeFromNpShaderType:shaderType ];
    glID = glCreateShader(glShaderType);

    // need a C string for GLSL compilation
    const char * glSource
        = [ shaderSource cStringUsingEncoding:NSUTF8StringEncoding ];

    glShaderSource(glID, 1, &glSource, NULL);
    glCompileShader(glID);

    // check if compilation went well
    if ( [ NPShader checkShaderCompileStatus:glID
                                       error:error ] == YES )
    {
        ready = YES;
    }

    return ready;
}

@end

@implementation NPShader (Private)

+ (NpShaderType) shaderTypeFromFileName:(NSString *)fileName
{
	NSString * fileExtension = [[ fileName pathExtension ] lowercaseString ];

	if ( [ fileExtension isEqual:@"vertex" ] == YES )
	{
		return NpShaderTypeVertex;
	}

	if ( [ fileExtension isEqual:@"fragment" ] == YES )
	{
		return NpShaderTypeFragment;
	}

	return NpShaderTypeUnknown;
}

+ (GLenum) glShaderTypeFromNpShaderType:(NpShaderType)shaderType
{
	switch ( shaderType )
	{
	case NpShaderTypeVertex:
		return GL_VERTEX_SHADER;
	case NpShaderTypeFragment:
		return GL_FRAGMENT_SHADER;
	default:
		return GL_NONE;	
	}
}

+ (BOOL) checkShaderCompileStatus:(GLuint)glID
                            error:(NSError **)error
{
    if ( glID == 0 )
	{
		return NO;
	}

	BOOL result = YES;

	GLint successful;
	glGetShaderiv(glID, GL_COMPILE_STATUS, &successful);

	if ( successful == GL_FALSE )
	{
		GLsizei infoLogLength = 0;
		GLsizei charsWritten = 0;

		glGetShaderiv(glID, GL_INFO_LOG_LENGTH, &infoLogLength);

		char* infoLog = ALLOC_ARRAY(char, infoLogLength);
		glGetShaderInfoLog(glID, infoLogLength, &charsWritten, infoLog);

        if ( error != NULL )
        {
            NSString * description = AUTORELEASE(
               [[ NSString alloc ] initWithBytes:infoLog
                                          length:infoLogLength
                                        encoding:NSASCIIStringEncoding ]);

            *error = [ NSError errorWithCode:NPEngineGraphicsShaderGLSLCompilationError
                                 description:description ];
        }

		FREE(infoLog);

		result = NO;
	}

	return result;
}

@end


