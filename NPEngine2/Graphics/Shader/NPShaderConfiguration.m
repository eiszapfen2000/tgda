#import <Foundation/NSArray.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "NPShader.h"
#import "NPShaderConfiguration.h"

@interface NPShaderConfiguration (Private)

+ (BOOL) checkProgramLinkStatus:(GLuint)glID
                          error:(NSError **)error
                               ;

- (void) clearShaders;
- (BOOL) linkProgram:(NSError **)error;

@end

@implementation NPShaderConfiguration

- (id) init
{
    return [ self initWithName:@"Shader Configuration" ];
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
    vertexShader = fragmentShader = nil;
    shaderVariables = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ shaderVariables removeAllObjects ];
    DESTROY(shaderVariables);

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

- (void) clear
{
	if ( glID > 0)
	{
        [ self clearShaders ];

		glDeleteProgram(glID);
		glID = 0;
	}

    [ shaderVariables removeAllObjects ];
    [ self setName:@"" ];
    SAFE_DESTROY(file);
    ready = NO;
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

    return NO;
}

@end

@implementation NPShaderConfiguration (Private)

+ (BOOL) checkProgramLinkStatus:(GLuint)glID
                          error:(NSError **)error
{
    if ( glID == 0 )
    {
        return NO;
    }

	BOOL result = YES;

	GLint successful;
	glGetProgramiv(glID, GL_LINK_STATUS, &successful);

	if (successful == GL_FALSE)
	{
		GLsizei infoLogLength = 0;
		GLsizei charsWritten = 0;

		glGetProgramiv(glID, GL_INFO_LOG_LENGTH, &infoLogLength);

		char * infoLog = ALLOC_ARRAY(char, infoLogLength);
		glGetProgramInfoLog(glID, infoLogLength, &charsWritten, infoLog);

        if ( error != NULL )
        {
            NSString * description = AUTORELEASE(
               [[ NSString alloc ] initWithBytes:infoLog
                                          length:infoLogLength
                                        encoding:NSASCIIStringEncoding ]);

            *error = [ NSError errorWithCode:NPEngineGraphicsShaderConfigurationGLSLLinkError
                                 description:description ];
        }

		FREE(infoLog);

		result = NO;
	}

	return result;
}

- (void) clearShaders
{
    if ( vertexShader != nil )
    {
        vertexShader = nil;
    }

    if ( fragmentShader != nil )
    {
        fragmentShader = nil;
    }
}

- (BOOL) linkProgram:(NSError **)error
{
    if ( vertexShader == nil || fragmentShader == nil )
    {
        if ( error != NULL )
        {
            NSString * description
                = [ NSString stringWithFormat:@"Shader missing in \"%@\"", name ];

            *error = [ NSError errorWithCode:NPEngineGraphicsShaderConfigurationShaderMissing
                                 description:description ];
        }

        return NO;
    }

    if ( [ vertexShader ready ] == NO
         || [ fragmentShader ready ] == NO )
    {
        if ( error != NULL )
        {
            NSString * description
                = [ NSString stringWithFormat:@"Shader corrupt in \"%@\"", name ];

            *error = [ NSError errorWithCode:NPEngineGraphicsShaderConfigurationShaderCorrupt
                                 description:description ];
        }

        return NO;        
    }

	glAttachShader(glID, [ vertexShader glID ]);
	glAttachShader(glID, [ fragmentShader glID ]);
	glLinkProgram(glID);

    if ( [ NPShaderConfiguration checkProgramLinkStatus:glID
                                                  error:error ] == YES )
    {
        ready = YES;
    }

    return ready;
}

@end


