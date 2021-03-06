#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Container/NSArray+NPPObject.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NpTextureSamplerParameter.h"
#import "Graphics/Texture/NPTextureSamplingState.h"
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
#import "NPEffectVariableInt.h"
#import "NPEffectVariableBool.h"
#import "NPEffect.h"
#import "NPEffectTechniqueVariable.h"
#import "NPEffectTechnique.h"

static NPEffectTechnique * currentTechnique = nil;
static BOOL locked = NO;

@interface NPEffect (Technique)

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
        insertPreprocessorDefines:(NPStringList *)preprocessorDefines
            insertEffectVariables:(NPStringList *)effectVariables
                    insertStreams:(NPStringList *)streams
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
              preprocessorDefines:(NPStringList *)preprocessorDefines
                  effectVariables:(NPStringList *)effectVariables
                    vertexStreams:(NPStringList *)vertexStreams
                                 ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                preprocessorDefines:(NPStringList *)preprocessorDefines
                    effectVariables:(NPStringList *)effectVariables
                    fragmentStreams:(NPStringList *)fragmentStreams
                                   ;

- (NPStringList *) extractPreprocessorLines:(NPStringList *)stringList;
- (NPStringList *) extractUniformLines:(NPStringList *)stringList;
- (NPStringList *) extractStreamLines:(NPStringList *)stringList;

- (void) parseShader:(NPParser *)parser
 preprocessorDefines:(NPStringList *)preprocessorDefines
     effectVariables:(NPStringList *)effectVariables
       vertexStreams:(NPStringList *)vertexStreams
     fragmentStreams:(NPStringList *)fragmentStreams
                    ;

- (void) parseVertexStreams:(NPStringList *)vertexStreamLines;
- (void) parseFragmentStreams:(NPStringList *)fragmentStreamLines;

- (void) clearShaders;
- (BOOL) linkShader:(NSError **)error;
- (void) parseSamplerVariable:(NPParser *)parser
                       atLine:(NSUInteger)line
                             ;
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

	GLint successful;
	glGetProgramiv(glID, GL_LINK_STATUS, &successful);

	if ( successful == GL_TRUE )
	{
		return YES;
	}

	GLsizei infoLogLength = 0;
	glGetProgramiv(glID, GL_INFO_LOG_LENGTH, &infoLogLength);

	if ( infoLogLength == 0 )
	{
		return NO;
	}

    if ( error != NULL )
    {
        char infoLog[infoLogLength];
        glGetProgramInfoLog(glID, infoLogLength, &infoLogLength, infoLog);

        NSString * description
            = AUTORELEASE([[ NSString alloc ] 
                                initWithCString:infoLog
                                       encoding:NSASCIIStringEncoding ]);

        *error = [ NSError errorWithCode:NPEngineGraphicsEffectTechniqueGLSLLinkError
                             description:description ];
    }
	
	return NO;
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

- (NPEffectTechniqueVariable *) techniqueVariableWithName:(NSString *)variableName
{
    return [ techniqueVariables objectWithName:variableName ];
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    [ self clear ];

    NSAssert(effect != nil, @"Technique does not belong to an effect");

    NPLOG(@"Loading effect technique \"%@\"", name);

    NPParser * parser = AUTORELEASE([[ NPParser alloc ] init ]);
    [ parser parse:stringList ];

    NPStringList * preprocessorLines    = [ NPStringList stringList ];
    NPStringList * uniformVariableLines = [ NPStringList stringList ];
    NPStringList * vertexStreamLines    = [ NPStringList stringList ];
    NPStringList * fragmentStreamLines  = [ NPStringList stringList ];

    [ preprocessorLines    addStringList:[ stringList stringsWithPrefix:@"define"  ]];
    [ uniformVariableLines addStringList:[ stringList stringsWithPrefix:@"uniform" ]];
    [ vertexStreamLines    addStringList:[ stringList stringsWithPrefix:@"in"      ]];
    [ fragmentStreamLines  addStringList:[ stringList stringsWithPrefix:@"out"     ]];

    NPStringList * preprocessorLinesStripped
        = [ self extractPreprocessorLines:preprocessorLines ];

    // separate uniform related strings at ":" and append ";"
    NPStringList * uniformVariableLinesStripped
        = [ self extractUniformLines:uniformVariableLines ];

    // separate stream related strings at ":", trim first component
    // and append ";"
    NPStringList * vertexStreamLinesStripped
        = [ self extractStreamLines:vertexStreamLines ];

    NPStringList * fragmentStreamLinesStripped
        = [ self extractStreamLines:fragmentStreamLines ];

    // assemble and compile shaders
    [ self parseShader:parser
   preprocessorDefines:preprocessorLinesStripped
       effectVariables:uniformVariableLinesStripped 
         vertexStreams:vertexStreamLinesStripped
       fragmentStreams:fragmentStreamLinesStripped ];

    glID = glCreateProgram();
	if (glIsProgram(glID) == GL_FALSE)
	{
        // error
		return NO;
	}

    // bind vertex attribute input locations
    [ self parseVertexStreams:vertexStreamLines ];
    // bind fragment output locations
    [ self parseFragmentStreams:fragmentStreamLines ];

    if ( [ self linkShader:error ] == NO )
    {
        return NO;
    }

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
    [[[ NPEngineGraphics instance ] textureSamplingState ] activate ];
}

@end

@implementation NPEffect (Technique)

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

        NSAssert3([ v texelUnit ] == texelUnit,
             @"Cannot bind sampler \"%@\" to texel unit %u, already bound to texel unit %u",
             variableName, texelUnit, [ v texelUnit ]);

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
        insertPreprocessorDefines:(NPStringList *)preprocessorDefines
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

    NPStringList * linesToInsert = [ NPStringList stringList ];
    [ linesToInsert addStringList:preprocessorDefines ];
    [ linesToInsert addStringList:effectVariables ];
    [ linesToInsert addStringList:streams ];

    [ shaderSource insertStringList:linesToInsert
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
              preprocessorDefines:(NPStringList *)preprocessorDefines
                  effectVariables:(NPStringList *)effectVariables
                    vertexStreams:(NPStringList *)vertexStreams
{
    SAFE_DESTROY(vertexShader);

    NPLOG(@"Loading vertex shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
          insertPreprocessorDefines:preprocessorDefines
              insertEffectVariables:effectVariables
                      insertStreams:vertexStreams ];

    if ( shader != nil )
    {
        vertexShader = RETAIN(shader);
    }
}

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                preprocessorDefines:(NPStringList *)preprocessorDefines
                    effectVariables:(NPStringList *)effectVariables
                    fragmentStreams:(NPStringList *)fragmentStreams
{
    SAFE_DESTROY(fragmentShader);

    NPLOG(@"Loading fragment shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
          insertPreprocessorDefines:preprocessorDefines
              insertEffectVariables:effectVariables
                      insertStreams:fragmentStreams ];

    if ( shader != nil )
    {
        fragmentShader = RETAIN(shader);
    }
}

- (NPStringList *) extractPreprocessorLines:(NPStringList *)stringList
{
    NPStringList * result = [ NPStringList stringList ];
    NSCharacterSet * whitespace = [ NSCharacterSet whitespaceCharacterSet ];

    // assemble "#define FOO VALUE" or just "#define FOO"
    NSUInteger numberOfStrings = [ stringList count ];
    for (NSUInteger i = 0; i < numberOfStrings; i++)
    {
        NSString * trimmedString
            = [[ stringList stringAtIndex:i ] stringByTrimmingCharactersInSet:whitespace ];

        NSArray * components
            = [ trimmedString componentsSeparatedByCharactersInSet:whitespace ];

        NSUInteger componentCount = [ components count ];

        if (componentCount < 2 || componentCount > 3)
        {
            continue;
        }

        NSString * line = @"#";
        for (NSUInteger c = 0; c < componentCount; c++)
        {
            line = [ line stringByAppendingFormat:@"%@ ", [ components objectAtIndex:c ]];
        }

        [ result addString:line ];
    }

    return result;
}

- (NPStringList *) extractUniformLines:(NPStringList *)stringList
{
    NPStringList * result = [ NPStringList stringList ];
    NSCharacterSet * whitespace = [ NSCharacterSet whitespaceCharacterSet ];

    NSUInteger c = [ stringList count ];
    for ( NSUInteger i = 0; i < c; i++ )
    {
        NSString * s = [ stringList stringAtIndex:i ];
        NSString * trimmed
            = [ s stringByTrimmingCharactersInSet:whitespace ];

        NSMutableArray * components
            = [[ trimmed
                    componentsSeparatedByCharactersInSet:whitespace ]
                        mutableCopy ];

        [ components removeObject:@"" ];
 
        if ( [ components count ] > 3 )
        {
            NSArray * a = [ components subarrayWithRange:NSMakeRange(0,3) ];
            s = [ a componentsJoinedByString:@" "];
        }

        // append semicolon if necessary
        if ( [ s hasSuffix:@";" ] == NO )
        {
            s = [ s stringByAppendingString:@";" ];
        }

        [ result addString:s ];
    }

    return result;
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
 preprocessorDefines:(NPStringList *)preprocessorDefines
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
                            preprocessorDefines:preprocessorDefines
                                effectVariables:effectVariables
                                  vertexStreams:vertexStreams ];
            }

            if ( [ shaderType isEqual:@"fragment" ] == YES )
            {
                [ self loadFragmentShaderFromFile:shaderFileName
                              preprocessorDefines:preprocessorDefines
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

- (void) parseSamplerVariable:(NPParser *)parser
                       atLine:(NSUInteger)line
{

}

- (void) parseEffectVariables:(NPParser *)parser
{
    const uint32_t nTexelUnits
        = [[[ NPEngineGraphics instance ] textureBindingState ] numberOfSuppertedTexelUnits ];

    BOOL * texelUnits = ALLOC_ARRAY(BOOL, nTexelUnits);
    memset(texelUnits, 0, sizeof(BOOL) * nTexelUnits);

    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {
        if ( [ parser tokenCountForLine:i ] > 2
             && [ parser isLowerCaseTokenFromLine:i atPosition:0 equalToString:@"uniform" ] == YES )
        {
            NSString * uniformType = [ parser getTokenFromLine:i atPosition:1 ];
            NSString * uniformName = [ parser getTokenFromLine:i atPosition:2 ];

            if ( [ uniformType hasPrefix:@"sampler" ] == YES )
            {
                uint32_t texelUnit;
                if ( [ parser tokenCountForLine:i ] == 5
                     && [ parser isTokenFromLine:i atPosition:3 equalToString:@":" ] == YES
                     && [ parser getTokenAsUInt:&texelUnit fromLine:i atPosition:4 ] == YES)
                {
                    NSAssert3(texelUnit < nTexelUnits,
                        @"Sampler \"%@\": Texelunit %u exceeds available Texelunits %u",
                        uniformName, texelUnit, nTexelUnits);

                    NSAssert2(texelUnits[texelUnit] == NO,
                        @"Sampler \"%@\": Texelunit %u is already in use",
                        uniformName, texelUnit);

                    texelUnits[texelUnit] = YES;
                }
                else
                {
                    for (texelUnit = 0; texelUnit < nTexelUnits; texelUnit++)
                    {
                        if (texelUnits[texelUnit] == NO)
                        {
                            texelUnits[texelUnit] = YES;
                            break;
                        }
                    }
                }                

                NPEffectVariableSampler * sampler
                    = [ effect registerEffectVariableSampler:uniformName
                                                   texelUnit:texelUnit ];

                NSRange lineRange = NSMakeRange(ULONG_MAX, 0);

                if ( [ parser isTokenFromLine:i+1 atPosition:0 equalToString:@"{" ] == YES )
                {
                    // inside sampler, find end
                    for ( NSUInteger j = i + 2; j < numberOfLines; j++ )
                    {
                        if ( [ parser isTokenFromLine:j atPosition:0 equalToString:@"}" ] == YES )
                        {
                            lineRange.location = i + 2;
                            lineRange.length = j - ( i + 2 );

                            // exit the inner loop since we are
                            // done with the sampler
                            break;
                        }
                    }
                }

                if ( lineRange.location != ULONG_MAX )
                {
                    NpSamplerFilterState filterState;
                    NpSamplerWrapState wrapState;
                    reset_sampler_filterstate(&filterState);
                    reset_sampler_wrapstate(&wrapState);

                    for ( NSUInteger j = lineRange.location; j < lineRange.location + lineRange.length; j++ )
                    {
                        NSString * fieldName  = NULL;
                        NSString * fieldValue = NULL;

                        if ( [ parser getTokenAsLowerCaseString:&fieldName fromLine:j atPosition:0 ] == YES
                             && [ parser isTokenFromLine:j atPosition:1 equalToString:@"=" ] == YES
                             && [ parser getTokenAsLowerCaseString:&fieldValue fromLine:j atPosition:2 ] == YES)
                        {
                            if ( [ fieldName isEqual:@"wraps" ] == YES )
                            {
                                wrapState.wrapS
                                    = [ fieldValue textureWrapValueWithDefaultValue:wrapState.wrapS ];
                            }

                            if ( [ fieldName isEqual:@"wrapt" ] == YES )
                            {
                                wrapState.wrapT
                                    = [ fieldValue textureWrapValueWithDefaultValue:wrapState.wrapT ];
                            }

                            if ( [ fieldName isEqual:@"wrapr" ] == YES )
                            {
                                wrapState.wrapR
                                    = [ fieldValue textureWrapValueWithDefaultValue:wrapState.wrapR ];
                            }

                            if ( [ fieldName isEqual:@"minfilter" ] == YES )
                            {
                                filterState.minFilter
                                    = [ fieldValue textureMinFilterValueWithDefault:filterState.minFilter ];
                            }

                            if ( [ fieldName isEqual:@"magfilter" ] == YES )
                            {
                                filterState.magFilter
                                    = [ fieldValue textureMagFilterValueWithDefault:filterState.magFilter ];
                            }

                            if ( [ fieldName isEqual:@"anisotropy" ] == YES )
                            {
                                filterState.anisotropy
                                    = MAX(0, [ fieldValue intValue ]);
                            }
                        }
                    }

                    [ sampler setFilterState:filterState ];
                    [ sampler setWrapState:wrapState ];
                }
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

    FREE(texelUnits);
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
		GLsizei uniformNameLength = -1;
		GLint uniformSize = -1;
		GLenum uniformType = GL_NONE;
        GLint uniformLocation;
		char uniformName[maxUniformNameLength];
        memset(uniformName, 0, maxUniformNameLength);

		glGetActiveUniform(glID, i, maxUniformNameLength, &uniformNameLength,
			&uniformSize, &uniformType, uniformName);

        // no information, probable cause: link failed
        if (( uniformNameLength == 0 ) && ( strlen(uniformName) == 0))
        {
            // print something
            continue;
        }

        // even less information, error
        if (( uniformNameLength == -1 ) || ( uniformSize == -1 )
            || ( uniformType == GL_NONE ))
        {
            // print something
            continue;
        }

        uniformLocation = glGetUniformLocation(glID, uniformName);

        if ( uniformLocation == -1 )
        {
            // print something
            continue;
        }

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

    NSAssert([ techniqueVariables count ] == (NSUInteger)numberOfActiveUniforms,
             @"Active uniform parse error");
}

- (void) activateVariables
{
    [ techniqueVariables makeObjectsPerformSelector:@selector(activate) ];
}

@end

