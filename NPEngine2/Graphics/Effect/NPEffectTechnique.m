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

- (id) registerEffectVariableSemantic:(NSString *)variableName;
- (id) registerEffectVariableSampler:(NSString *)variableName;
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
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
                  effectVariables:(NPStringList *)effectVariables
                                 ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                    effectVariables:(NPStringList *)effectVariables
                                   ;

- (NPStringList *) extractEffectVariableLines:(NPStringList *)stringList;
- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
                    ;

- (void) clearShaders;
- (BOOL) linkShader:(NSError **)error;
- (void) parseEffectVariables:(NPParser *)parser;
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

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    [ self clear ];

    NSAssert(effect != nil, @"Technique does not belong to an effect");

    NPParser * parser = AUTORELEASE([[ NPParser alloc ] init ]);
    [ parser parse:stringList ];

    NPStringList * effectVariableLines
        = [ self extractEffectVariableLines:stringList ];

    [ self parseShader:parser effectVariables:effectVariableLines ];

    glID = glCreateProgram();

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
    glUseProgram(glID);

    [ self activateVariables ];
}

@end

@implementation NPEffect (Private)

- (id) registerEffectVariableSemantic:(NSString *)variableName
{
    NPEffectVariableSemantic * v = [ self variableWithName:variableName ];

    if ( v != nil )
    {
        NSAssert1([ v variableType ] == NpEffectVariableTypeSemantic,
             @"Effect Variable \"%@\" is not a semantic", variableName);

        return v;
    }

    v = [[ NPEffectVariableSemantic alloc ] initWithName:variableName ];
    [ variables addObject:v ];

    return AUTORELEASE(v);
}

- (id) registerEffectVariableSampler:(NSString *)variableName
{
    NPEffectVariableSampler * v = [ self variableWithName:variableName ];

    if ( v != nil )
    {
        NSAssert1([ v variableType ] == NpEffectVariableTypeSampler,
             @"Effect Variable \"%@\" is not a sampler", variableName);

        return v;
    }

    v = [[ NPEffectVariableSampler alloc ] initWithName:variableName ];
    [ variables addObject:v ];

    return AUTORELEASE(v);
}

- (id) registerEffectVariableUniform:(NSString *)variableName
                        uniformClass:(Class)uniformClass
{
    NSAssert1(uniformClass != Nil, @"%s - uniformClass is Nil",
        __PRETTY_FUNCTION__);

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

    [ shaderSource insertStringList:effectVariables atIndex:0 ];

    NPLOG([shaderSource description]);

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
{
    SAFE_DESTROY(vertexShader);

    NPLOG(@"Loading vertex shader \"%@\"", fileName);

    NPShader * shader
        = [ self loadShaderFromFile:fileName
              insertEffectVariables:effectVariables ];

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
              insertEffectVariables:effectVariables ];

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

- (void) parseShader:(NPParser *)parser
     effectVariables:(NPStringList *)effectVariables
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
                                effectVariables:effectVariables ];
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
                //NPEffectVariableSampler * s = [ effect registerEffectVariableSampler:uniformName ];
            }
            else if ( [ uniformName hasPrefix:@"np_" ] == YES )
            {
                NPEffectVariableSemantic * s = [ effect registerEffectVariableSemantic:uniformName ];
                NpEffectSemantic semantic = [[ uniformName lowercaseString ] semanticValue ];
                [ s setSemantic:semantic ];
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
                                           encoding:NSUTF8StringEncoding ]);

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

- (void) parseActiveVariables
{
	GLint numberOfActiveUniforms;
    GLint maxUniformNameLength;

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

        NSString * uName
            = [[ NSString alloc ] initWithCString:uniformName
                                         encoding:NSUTF8StringEncoding ];

        BOOL isSampler = NO;

		// Sampler
		switch (uniformType)
		{
		case GL_SAMPLER_1D:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_3D:
		case GL_SAMPLER_CUBE:
		case GL_SAMPLER_BUFFER_EXT:
            {
                isSampler = YES;
                break;
            }
		}

        if ( isSampler == NO )
        {
            NPEffectTechniqueVariable * vt
                = AUTORELEASE([[ NPEffectTechniqueVariable alloc ]
                                    initWithName:uName
                                  effectVariable:[ effect variableWithName:uName ]
                                        location:i ]);

            [ techniqueVariables addObject:vt ];
        }

        /*
		// Other
		if ((shaderVariableName.length() < 3) || ((shaderVariableName.substr(0, 3) != "zt_") && (shaderVariableName.substr(0, 3) != "gl_")))
		{
			ZtShaderVariableUniform* uniformVariable = getShaderVariableUniform(shaderVariableName);
			uniformVariable->setGLID(i);

			switch (uniformType)
			{
			case GL_BOOL:
				uniformVariable->setUniformType(VARIABLETYPE_BOOLEAN);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_BOOLEAN);
				break;
			case GL_INT:
				uniformVariable->setUniformType(VARIABLETYPE_INTEGER);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_INTEGER);
				break;
			case GL_FLOAT:
				uniformVariable->setUniformType(VARIABLETYPE_FLOAT);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_FLOAT);
				break;
			case GL_FLOAT_VEC2:
				uniformVariable->setUniformType(VARIABLETYPE_VECTOR2);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_VECTOR2);
				break;
			case GL_FLOAT_VEC3:
				uniformVariable->setUniformType(VARIABLETYPE_VECTOR3);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_VECTOR3);
				break;
			case GL_FLOAT_VEC4:
				uniformVariable->setUniformType(VARIABLETYPE_VECTOR4);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_VECTOR4);
				break;
			case GL_FLOAT_MAT2:
				uniformVariable->setUniformType(VARIABLETYPE_MATRIX2x2);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_MATRIX2x2);
				break;
			case GL_FLOAT_MAT3:
				uniformVariable->setUniformType(VARIABLETYPE_MATRIX3x3);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_MATRIX3x3);
				break;
			case GL_FLOAT_MAT4:
				uniformVariable->setUniformType(VARIABLETYPE_MATRIX4x4);
				ztMaterialVariablePool()->getMaterialVariable(shaderVariableName, VARIABLETYPE_MATRIX4x4);
				break;
			}
		}
        */
	}
}

- (void) activateVariables
{
    [ techniqueVariables makeObjectsPerformSelector:@selector(activate) ];
}

@end

