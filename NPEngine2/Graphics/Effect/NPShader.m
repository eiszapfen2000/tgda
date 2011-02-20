#import "Log/NPLog.h"
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/String/NPStringList.h"
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

+ (id) shaderFromStringList:(NPStringList *)source
                      error:(NSError **)error
{
    NPShader * shader = [[ NPShader alloc ] init ];
    if ( [ shader loadFromStringList:source
                               error:error ] == NO )
    {
        DESTROY(shader);
        return nil;
    }

    return AUTORELEASE(shader);
}

+ (id) shaderFromStream:(id <NPPStream>)stream
                  error:(NSError **)error
{
    NPShader * shader = [[ NPShader alloc ] init ];
    if ( [ shader loadFromStream:stream
                           error:error ] == NO )
    {
        DESTROY(shader);
        return nil;
    }

    return AUTORELEASE(shader);
}

+ (id) shaderFromFile:(NSString *)fileName
                error:(NSError **)error
{
    NPShader * shader = [[ NPShader alloc ] init ];
    if ( [ shader loadFromFile:fileName
                         error:error ] == NO )
    {
        DESTROY(shader);
        return nil;
    }

    return AUTORELEASE(shader);
}

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

    return self;
}

- (void) dealloc
{
    [ self clear ];
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

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    // determine shader type from file extensions
    shaderType = [ NPShader shaderTypeFromFileName:[ stringList fileName ]];
    if ( shaderType == NpShaderTypeUnknown )
    {
        return NO;
    }

    // determine GL shader type
    GLenum glShaderType = [ NPShader glShaderTypeFromNpShaderType:shaderType ];
    glID = glCreateShader(glShaderType);

    NSUInteger numberOfLines = [ stringList count ];
    const GLchar ** lineCStrings = ALLOC_ARRAY(const GLchar *, numberOfLines);
    for (NSUInteger i = 0; i < numberOfLines; i++ )
    {
        lineCStrings[i]
            = [[ stringList stringAtIndex:i ] 
                     cStringUsingEncoding:NSUTF8StringEncoding ];
    }

    glShaderSource(glID, (GLsizei)numberOfLines, lineCStrings, NULL);
    glCompileShader(glID);

    // check if compilation went well
    if ( [ NPShader checkShaderCompileStatus:glID
                                       error:error ] == YES )
    {
        ready = YES;
    }

    return ready;
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

    NPStringList * stringList
        = AUTORELEASE([[ NPStringList alloc ]
                             initWithName:@""
                                   parent:self
                          allowDuplicates:YES
                        allowEmptyStrings:YES ]);

    if ( [ stringList loadFromFile:completeFileName
                             error:error ] == NO )
    {
        return NO;
    }

    return [ self loadFromStringList:stringList error:error ];
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
            NSString * description
                = AUTORELEASE([[ NSString alloc ] 
                                    initWithCString:infoLog
                                           encoding:NSUTF8StringEncoding ]);

            *error = [ NSError errorWithCode:NPEngineGraphicsShaderGLSLCompilationError
                                 description:description ];
        }

		FREE(infoLog);

		result = NO;
	}

	return result;
}

@end


