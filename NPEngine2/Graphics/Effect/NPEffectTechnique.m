#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "Graphics/NSString+NPEngineGraphicsClasses.h"
#import "NPShader.h"
#import "NPEffectVariable.h"
#import "NPEffectVariableSampler.h"
#import "NPEffectVariableSemantic.h"
#import "NPEffectVariableUniform.h"
#import "NPEffectVariableFloat.h"
#import "NPEffect.h"
#import "NPEffectTechniqueVariable.h"
#import "NPEffectTechnique.h"

static NPEffectTechnique * currentTechnique = nil;
static BOOL locked = NO;

@interface NPEffect (Private)

- (id) registerEffectVariableSampler:(NSString *)variableName
                           texelUnit:(uint32_t)texelUnit
                                    ;

- (id) registerEffectVariableSemantic:(NSString *)variableName
                             semantic:(NpEffectSemantic)semantic
                                     ;

- (id) registerEffectVariableUniform:(NSString *)variableName
                        uniformClass:(Class)uniformClass
                                    ;
@end

@interface NPEffectTechnique (Private)

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NPStringList *)effectVariables
                    insertStreams:(NPStringList *)streams
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
                  effectVariables:(NPStringList *)effectVariables
                    vertexStreams:(NPStringList *)vertexStreams
                                 ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                    effectVariables:(NPStringList *)effectVariables
                    fragmentStreams:(NPStringList *)fragmentStreams
                                   ;

- (NPStringList *) extractStreamLines:(NPStringList *)stringList;

- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
       vertexStreams:(NPStringList *)vertexStreams
     fragmentStreams:(NPStringList *)fragmentStreams
                    ;

- (void) parseVertexStreams:(NPStringList *)vertexStreamLines;
- (void) parseFragmentStreams:(NPStringList *)fragmentStreamLines;

- (void) clearShaders;
- (BOOL) linkShader:(NSError **)error;
- (void) parseEffectVariables:(NPParser *)parser;
- (void) parseActiveVariables;
- (void) activateVariables;

@end

@implementation NPEffectTechnique

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

	if ( successful == GL_FALSE )
	{
		GLsizei infoLogLength = 0;
		GLsizei charsWritten = 0;

		glGetProgramiv(glID, GL_INFO_LOG_LENGTH, &infoLogLength);

		char* infoLog = ALLOC_ARRAY(char, (size_t)infoLogLength);
		glGetProgramInfoLog(glID, infoLogLength, &charsWritten, infoLog);

        if ( error != NULL )
        {
            NSString * description
                = AUTORELEASE([[ NSString alloc ] 
                                    initWithCString:infoLog
                                           encoding:NSASCIIStringEncoding ]);

            *error = [ NSError errorWithCode:NPEngineGraphicsEffectTechniqueGLSLLinkError
                                 description:description ];
        }
		
		FREE(infoLog);

		result = NO;
	}

	return result;
}

+ (void) activate
{
    if ( currentTechnique != nil )
    {
        [ currentTechnique activateVariables ];
    }
}

+ (void) deactivate
{
    if (( currentTechnique != nil ) && ( locked == NO ))
    {
        glUseProgram(0);
        currentTechnique = nil;
    }
}

- (id) initWithName:(NSString *)newName
             effect:(NPEffect *)newEffect
{
    self = [ super initWithName:newName ];

    vertexShader = fragmentShader = nil;
    effect = newEffect;
    techniqueVariables = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ self clear ];
    DESTROY(techniqueVariables);

    [ super dealloc ];
}

- (void) clear
{
    if ( glID != 0 )
    {
        [ self clearShaders ];

        glDeleteProgram(glID);
		glID = 0;
    }

    [ techniqueVariables removeAllObjects ];
}

- (void) lock
{
    locked = YES;
}

- (void) unlock
{
    locked = NO;
}

- (GLuint) glID
{
    return glID;
}

- (NPShader *) vertexShader
{
    return vertexShader;
}

- (NPShader *) fragmentShader
{
    return fragmentShader;
}

- (NPEffect *) effect
{
    return effect;
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    [ self clear ];

    NSAssert(effect != nil, @"Technique does not belong to an effect");

    NPLOG(@"Loading effect technique \"%@\"", name);

    NPParser * parser = AUTORELEASE([[ NPParser alloc ] init ]);
    [ parser parse:stringList ];

    NPStringList * effectVariableLines = [ NPStringList stringList ];
    NPStringList * vertexStreamLines   = [ NPStringList stringList ];
    NPStringList * fragmentStreamLines = [ NPStringList stringList ];

    [ effectVariableLines addStringList:[ stringList stringsWithPrefix:@"uniform" ]];
    [ vertexStreamLines   addStringList:[ stringList stringsWithPrefix:@"in"  ]];
    [ fragmentStreamLines addStringList:[ stringList stringsWithPrefix:@"out" ]];

    // separate stream related strings at ":", trim first component
    // and append ";"
    NPStringList * vertexStreamLinesStripped
        = [ self extractStreamLines:vertexStreamLines ];

    NPStringList * fragmentStreamLinesStripped
        = [ self extractStreamLines:fragmentStreamLines ];

    [ self parseShader:parser
       effectVariables:effectVariableLines 
         vertexStreams:vertexStreamLinesStripped
       fragmentStreams:fragmentStreamLinesStripped ];

    glID = glCreateProgram();
	if (glIsProgram(glID) == GL_FALSE)
	{
        // error
		return NO;
	}

    [ self parseVertexStreams:vertexStreamLines ];
    [ self parseFragmentStreams:fragmentStreamLines ];

    if ( [ self linkShader:error ] == NO )
    {
        return NO;
    }

    [ parser parse:effectVariableLines ];
    [ self parseEffectVariables:parser ];
    [ self parseActiveVariables ];

    return YES;
}

- (void) activate
{
    [ self activate:NO ];
}

- (void) activate:(BOOL)force
{
    if (( currentTechnique != self ) && (locked == NO || force == YES ))
    {
        glUseProgram(glID);
        currentTechnique = self;
    }

    [ currentTechnique activateVariables ];
}

@end

@implementation NPEffect (Private)

- (id) registerEffectVariableSemantic:(NSString *)variableName
                             semantic:(NpEffectSemantic)semantic
{
    NPEffectVariableSemantic * v = [ self variableWithName:variableName ];

    if ( v != nil )
    {
        NSAssert1([ v variableType ] == NpEffectVariableTypeSemantic,
             @"Effect Variable \"%@\" is not a semantic", variableName);

        return v;
    }

    v = [[ NPEffectVariableSemantic alloc ] 
                           initWithName:variableName
                               semantic:semantic ];

    [ variables addObject:v ];

    return AUTORELEASE(v);
}

- (id) registerEffectVariableSampler:(NSString *)variableName
                           texelUnit:(uint32_t)texelUnit
{
    NPEffectVariableSampler * v = [ self variableWithName:variableName ];

    if ( v != nil )
    {
        NSAssert1([ v variableType ] == NpEffectVariableTypeSampler,
             @"Effect Variable \"%@\" is not a sampler", variableName);

        return v;
    }

    v = [[ NPEffectVariableSampler alloc ]
                           initWithName:variableName
                              texelUnit:texelUnit ];

    [ variables addObject:v ];

    return AUTORELEASE(v);
}

- (id) registerEffectVariableUniform:(NSString *)variableName
                        uniformClass:(Class)uniformClass
{
    NSAssert(uniformClass != Nil, @"UniformClass is Nil");

    id v = [ self variableWithName:variableName ];

    if ( v != nil )
    {
        NSAssert2([ v class ] == uniformClass,
             @"Effect Variable \"%@\" is not of class %@",
             variableName, NSStringFromClass(uniformClass));

        return v;
    }

    v = [[ uniformClass alloc ] initWithName:variableName ];
    [ variables addObject:v ];

    return AUTORELEASE(v);
}

@end

@implementation NPEffectTechnique (Private)

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NPStringList *)effectVariables
                    insertStreams:(NPStringList *)streams
{
    NSError * error = nil;

    NPStringList * shaderSource = [ NPStringList stringList ];
    [ shaderSource setAllowDuplicates:YES ];

    if ( [ shaderSource loadFromFile:fileName
                           arguments:nil
                               error:&error ] == NO )
    {
        DESTROY(shaderSource);
        NPLOG_ERROR(error);
        return nil;
    }

    // #version needs to be the first string in the shader,
    // so we insert all effect variables afterwards
    NSUInteger startIndex = 0;
    NSUInteger vIndex
        = [ shaderSource indexOfLastStringWithPrefix:@"#version" ];

    if ( vIndex != NSNotFound )
    {
        startIndex = vIndex + 1;
    }

    NPStringList * variablesAndStreams = [ NPStringList stringList ];
    [ variablesAndStreams addStringList:effectVariables ];
    [ variablesAndStreams addStringList:streams ];

    [ shaderSource insertStringList:variablesAndStreams
                            atIndex:startIndex ];

    // DAMN FUCKING NVIDIA GLSL Compiler needs \n
    // after preprocessor directives, so we insert
    // new lines everywhere
    [ shaderSource appendStringToAllStrings:@"\n" ];

    NPShader * shader
        = [ NPShader shaderFromStringList:shaderSource
                                    error:&error ];

    if ( shader == nil )
    {
        NPLOG_ERROR(error);
    }

    return shader;
}

- (void) loadVertexShaderFromFile:(NSString *)fileName
                  effectVariables:(NPStringList *)effectVariables
                    vertexStreams:(NPStringList *)vertexStreams
{
    SAFE_DESTROY(vertexShader);

    NPLOG(@"Loading vertex shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables
                      insertStreams:vertexStreams ];

    if ( shader != nil )
    {
        vertexShader = RETAIN(shader);
    }
}

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                    effectVariables:(NPStringList *)effectVariables
                    fragmentStreams:(NPStringList *)fragmentStreams
{
    SAFE_DESTROY(fragmentShader);

    NPLOG(@"Loading fragment shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables
                      insertStreams:fragmentStreams ];

    if ( shader != nil )
    {
        fragmentShader = RETAIN(shader);
    }
}

- (NPStringList *) extractStreamLines:(NPStringList *)stringList
{
    NSCharacterSet * whitespace = [ NSCharacterSet whitespaceCharacterSet ];

    NPStringList * result = [ NPStringList stringList ];

    // separate strings at ":"
    NSUInteger numberOfStrings = [ stringList count ];
    for (NSUInteger i = 0; i < numberOfStrings; i++)
    {
        NSString * string = [ stringList stringAtIndex:i ];
        NSArray  * components = [ string componentsSeparatedByString:@":" ];
        NSString * component = [ components objectAtIndex:0];
        NSString * trimmed = [ component stringByTrimmingCharactersInSet:whitespace ];
        NSString * final = [ trimmed stringByAppendingString:@";" ];
        [ result addString:final ];
    }

    return result;
}

- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
       vertexStreams:(NPStringList *)vertexStreams
     fragmentStreams:(NPStringList *)fragmentStreams
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        NSString * shaderType = nil;
        NSString * shaderFileName = nil;

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"set" ] == YES
             && [ parser getTokenAsLowerCaseString:&shaderType fromLine:i atPosition:1 ] == YES
             && [ parser isLowerCaseTokenFromLine:i atPosition:2 equalToString:@"shader" ] == YES
             && [ parser getTokenAsString:&shaderFileName fromLine:i atPosition:3 ] == YES )
        {
            if ( [ shaderType isEqual:@"vertex" ] == YES )
            {
                [ self loadVertexShaderFromFile:shaderFileName
                                effectVariables:effectVariables
                                  vertexStreams:vertexStreams ];
            }

            if ( [ shaderType isEqual:@"fragment" ] == YES )
            {
                [ self loadFragmentShaderFromFile:shaderFileName
                                  effectVariables:effectVariables
                                  fragmentStreams:fragmentStreams ];
            }
        }
    }
}

- (void) parseVertexStreams:(NPStringList *)vertexStreamLines
{
    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:vertexStreamLines ];

    const NSUInteger numberOfLines = [ parser lineCount ];
    for (NSUInteger i = 0; i < numberOfLines; i++)
    {
        NSString * streamName;
        unsigned int streamBinding;

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"in" ] == YES
             && [ parser getTokenAsLowerCaseString:&streamName fromLine:i atPosition:2 ] == YES
             && [ parser isTokenFromLine:i atPosition:3 equalToString:@":"] == YES
             && [ parser getTokenAsUInt:&streamBinding fromLine:i atPosition:4 ] == YES )
        {
            glBindAttribLocation(glID, streamBinding,
                [ streamName cStringUsingEncoding:NSASCIIStringEncoding ]);
        }
    }

    DESTROY(parser);
}

- (void) parseFragmentStreams:(NPStringList *)fragmentStreamLines
{
    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:fragmentStreamLines ];

    const NSUInteger numberOfLines = [ parser lineCount ];
    for (NSUInteger i = 0; i < numberOfLines; i++)
    {
        NSString * streamName;
        unsigned int streamBinding;

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"out" ] == YES
             && [ parser getTokenAsLowerCaseString:&streamName fromLine:i atPosition:2 ] == YES
             && [ parser isTokenFromLine:i atPosition:3 equalToString:@":"] == YES
             && [ parser getTokenAsUInt:&streamBinding fromLine:i atPosition:4 ] == YES )
        {
            glBindFragDataLocation(glID, streamBinding,
                [ streamName cStringUsingEncoding:NSASCIIStringEncoding ]);
        }
    }

    DESTROY(parser);
}

- (void) parseEffectVariables:(NPParser *)parser
{
    uint32_t texelUnit = 0;
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        if ( [ parser tokenCountForLine:i ] == 3 
             && [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"uniform" ] == YES )
        {
            NSString * uniformType = [ parser getTokenFromLine:i atPosition:1 ];
            NSString * uniformName = [ parser getTokenFromLine:i atPosition:2 ];

            if ( [ uniformType hasPrefix:@"sampler" ] == YES )
            {
                [ effect registerEffectVariableSampler:uniformName
                                             texelUnit:texelUnit ];

                texelUnit = texelUnit + 1;
            }
            else if ( [ uniformName hasPrefix:@"np_" ] == YES )
            {
                NpEffectSemantic semantic = [[ uniformName lowercaseString ] semanticValue ];
                [ effect registerEffectVariableSemantic:uniformName
                                               semantic:semantic ];
            }
            else if ( [ uniformName hasPrefix:@"np_" ] == NO &&  [ uniformName hasPrefix:@"gl_" ] == NO )
            {
                [ effect registerEffectVariableUniform:uniformName
                                          uniformClass:[ uniformType uniformTypeClass ]];
            }
        }
    }
}

- (void) clearShaders
{
	if ( fragmentShader != nil )
	{
		glDetachShader(glID, [ fragmentShader glID ]);
		DESTROY(fragmentShader);
	}

    if ( geometryShader != nil )
    {
		glDetachShader(glID, [ geometryShader glID ]);
		DESTROY(geometryShader);
    }

	if ( vertexShader != nil )
	{
		glDetachShader(glID, [ vertexShader glID ]);
		DESTROY(vertexShader);
	}
}

- (BOOL) linkShader:(NSError **)error
{
    if ( vertexShader == nil )
    {
        if ( error != NULL )
        {
            NSString * description
                = [ NSString stringWithFormat:@"Technique %@ misses vertex shader", name ];

            *error = [ NSError errorWithCode:NPEngineGraphicsEffectTechniqueShaderMissing
                                 description:description ];
        }

        return NO;
    }

    if ( [ vertexShader ready ] == NO
         || ( geometryShader != nil && [ geometryShader ready ] == NO )
         || ( fragmentShader != nil && [ fragmentShader ready ] == NO ))
    {
        if ( error != NULL )
        {
            NSString * description
                = [ NSString stringWithFormat:@"Technique %@ has at least one corrupt shader", name ];

            *error = [ NSError errorWithCode:NPEngineGraphicsEffectTechniqueShaderCorrupt
                                 description:description ];
        }

        return NO;
    }

    NSAssert1(glID != 0, @"Technique %@ misses GL program ID", name);

    glAttachShader(glID, [ vertexShader glID ]);

    if ( geometryShader != nil )
    {
        glAttachShader(glID, [ geometryShader glID ]);
    }

    if ( fragmentShader != nil )
    {
        glAttachShader(glID, [ fragmentShader glID ]);
    }

	glLinkProgram(glID);

    return [ NPEffectTechnique checkProgramLinkStatus:glID error:error ];
}

- (void) parseActiveVariables
{
	GLint numberOfActiveUniforms = 0;
    GLint maxUniformNameLength = 0;

	glGetProgramiv(glID, GL_ACTIVE_UNIFORMS, &numberOfActiveUniforms);
	glGetProgramiv(glID, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniformNameLength);

	for (int32_t i = 0; i < numberOfActiveUniforms; i++)
	{
		GLsizei uniformNameLength;
		GLint uniformSize;
		GLenum uniformType;
        GLint uniformLocation;
		char uniformName[maxUniformNameLength];

		glGetActiveUniform(glID, i, maxUniformNameLength, &uniformNameLength,
			&uniformSize, &uniformType, uniformName);

        // because of INTEL driver
        uniformLocation = glGetUniformLocation(glID, uniformName);

        #warning FIXME: Check for valid values returned by glGetActiveUniform

        NSString * uName
            = [ NSString stringWithCString:uniformName
                                  encoding:NSASCIIStringEncoding ];

        NPEffectTechniqueVariable * vt
            = AUTORELEASE([[ NPEffectTechniqueVariable alloc ]
                                initWithName:uName
                              effectVariable:[ effect variableWithName:uName ]
                                    location:uniformLocation ]);

        [ techniqueVariables addObject:vt ];
	}
}

- (void) activateVariables
{
    [ techniqueVariables makeObjectsPerformSelector:@selector(activate) ];
}

@end

