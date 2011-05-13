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

+ (BOOL) checkProgramLinkStatus:(GLuint)glID
                          error:(NSError **)error
                               ;

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NPStringList *)effectVariables
                 insertAttributes:(NPStringList *)attributes
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
                  effectVariables:(NPStringList *)effectVariables
                       attributes:(NPStringList *)attributes
                                 ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                    effectVariables:(NPStringList *)effectVariables
                                   ;

- (NPStringList *) extractEffectVariableLines:(NPStringList *)stringList;
- (NPStringList *) extractVertexStreamAttributes:(NPStringList *)stringList;

- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
          attributes:(NPStringList *)attributes
                    ;

- (void) clearShaders;
- (BOOL) linkShader:(NSError **)error;
- (void) parseEffectVariables:(NPParser *)parser;
- (void) parseActiveAttributes;
- (void) parseActiveVariables;
- (void) activateVariables;

@end

@implementation NPEffectTechnique

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

- (GLuint) glID
{
    return glID;
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    [ self clear ];

    NSAssert(effect != nil, @"Technique does not belong to an effect");

    NPLOG(@"Loading effect technique \"%@\"", name);

    NPParser * parser = AUTORELEASE([[ NPParser alloc ] init ]);
    [ parser parse:stringList ];

    NPStringList * effectVariableLines
        = [ self extractEffectVariableLines:stringList ];

    NPStringList * vertexStreamAttributes
        = [ self extractVertexStreamAttributes:stringList ];

    [ self parseShader:parser
       effectVariables:effectVariableLines 
            attributes:vertexStreamAttributes ];

    glID = glCreateProgram();

    if ( [ self linkShader:error ] == NO )
    {
        return NO;
    }

    [ self parseActiveAttributes ];
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
    glUseProgram(glID);

    [ self activateVariables ];
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
                 insertAttributes:(NPStringList *)attributes
{
    NSError * error = nil;
    NPStringList * shaderSource
        = [ NPStringList stringListWithContentsOfFile:fileName
                                                error:&error ];

    if ( shaderSource == nil )
    {
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

    NPStringList * variablesAndAttributes
        = [ NPStringList stringListWithStringList:effectVariables ];

    if ( attributes != nil )
    {
        [ variablesAndAttributes addStringList:attributes ];
    }

    [ shaderSource insertStringList:variablesAndAttributes
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
                       attributes:(NPStringList *)attributes
{
    SAFE_DESTROY(vertexShader);

    NPLOG(@"Loading vertex shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables
                   insertAttributes:attributes ];

    if ( shader != nil )
    {
        vertexShader = RETAIN(shader);
    }
}

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                    effectVariables:(NPStringList *)effectVariables
{
    SAFE_DESTROY(fragmentShader);

    NPLOG(@"Loading fragment shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables
                   insertAttributes:nil ];

    if ( shader != nil )
    {
        fragmentShader = RETAIN(shader);
    }
}

- (NPStringList *) extractEffectVariableLines:(NPStringList *)stringList
{
    NPStringList * lines = [ NPStringList stringList ];
    [ lines setAllowDuplicates:NO ];

    [ lines addStringList:[ stringList stringsWithPrefix:@"uniform" ]];
    [ lines addStringList:[ stringList stringsWithPrefix:@"varying" ]];

    return lines;
}

- (NPStringList *) extractVertexStreamAttributes:(NPStringList *)stringList
{
    NPStringList * lines = [ NPStringList stringList ];
    [ lines setAllowDuplicates:NO ];

    [ lines addStringList:[ stringList stringsWithPrefix:@"attribute" ]];

    return lines;
}

- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
          attributes:(NPStringList *)attributes
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        NSString * shaderType = nil;
        NSString * shaderFileName = nil;

        //NSLog([[ parser getTokensForLine:i ] description]);

        if ( [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"set" ] == YES
             && [ parser getTokenAsLowerCaseString:&shaderType fromLine:i atPosition:1 ] == YES
             && [ parser isLowerCaseTokenFromLine:i atPosition:2 equalToString:@"shader" ] == YES
             && [ parser getTokenAsString:&shaderFileName fromLine:i atPosition:3 ] == YES )
        {
            if ( [ shaderType isEqual:@"vertex" ] == YES )
            {
                [ self loadVertexShaderFromFile:shaderFileName
                                effectVariables:effectVariables
                                     attributes:attributes ];
            }

            if ( [ shaderType isEqual:@"fragment" ] == YES )
            {
                [ self loadFragmentShaderFromFile:shaderFileName
                                  effectVariables:effectVariables ];
            }
        }
    }
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

	if ( vertexShader != nil )
	{
		glDetachShader(glID, [ vertexShader glID ]);
		DESTROY(vertexShader);
	}
}

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

		char* infoLog = ALLOC_ARRAY(char, infoLogLength);
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

- (BOOL) linkShader:(NSError **)error
{
    if ( vertexShader == nil || fragmentShader == nil )
    {
        if ( error != NULL )
        {
            NSString * description
                = [ NSString stringWithFormat:@"Technique %@ misses at least one shader", name ];

            *error = [ NSError errorWithCode:NPEngineGraphicsEffectTechniqueShaderMissing
                                 description:description ];
        }

        return NO;
    }

    if ( [ vertexShader ready ] == NO || [ fragmentShader ready ] == NO )
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

	glAttachShader(glID, [ vertexShader   glID ]);
	glAttachShader(glID, [ fragmentShader glID ]);

	glLinkProgram(glID);

    return [ NPEffectTechnique checkProgramLinkStatus:glID error:error ];
}

- (void) parseActiveAttributes
{
    GLint numberOfActiveAttributes = 0;
    GLint maxAttributeNameLength = 0;

    glGetProgramiv(glID, GL_ACTIVE_ATTRIBUTES, &numberOfActiveAttributes);
    glGetProgramiv(glID, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxAttributeNameLength);

	for (int32_t i = 0; i < numberOfActiveAttributes; i++)
    {
        GLsizei attributeNameLength;
        GLint attributeSize;
        GLenum attributeType;
        GLchar attributeName[maxAttributeNameLength];

        glGetActiveAttrib(glID, i, maxAttributeNameLength, &attributeNameLength,
            &attributeSize, &attributeType, attributeName);

        #warning FIXME: Check for valid values returned by glGetActiveAttrib
    }
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
		char uniformName[maxUniformNameLength];

		glGetActiveUniform(glID, i, maxUniformNameLength, &uniformNameLength,
			&uniformSize, &uniformType, uniformName);

        #warning FIXME: Check for valid values returned by glGetActiveUniform

        NSString * uName
            = [ NSString stringWithCString:uniformName
                                  encoding:NSASCIIStringEncoding ];

        NPEffectTechniqueVariable * vt
            = AUTORELEASE([[ NPEffectTechniqueVariable alloc ]
                                initWithName:uName
                              effectVariable:[ effect variableWithName:uName ]
                                    location:i ]);

        [ techniqueVariables addObject:vt ];
	}
}

- (void) activateVariables
{
    [ techniqueVariables makeObjectsPerformSelector:@selector(activate) ];
}

@end

