#import <Foundation/NSException.h>
#import <Foundation/NSIndexSet.h>
#import "Log/NPLog.h"
#import "Core/String/NPStringList.h"
#import "Core/String/NPParser.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "NPShader.h"
#import "NPEffect.h"
#import "NPEffectTechnique.h"

@interface NPEffectTechnique (Private)

+ (BOOL) checkProgramLinkStatus:(GLuint)glID
                          error:(NSError **)error
                               ;

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NSArray *)effectVariables
                                 ;

- (void) loadVertexShaderFromFile:(NSString *)fileName
                 effectVariables:(NSArray *)effectVariables
                                ;

- (void) loadFragmentShaderFromFile:(NSString *)fileName
                   effectVariables:(NSArray *)effectVariables
                                  ;

- (NSArray *) extractEffectVariableLines:(NPStringList *)stringList;
- (void) parseShader:(NPParser *)parser
     effectVariables:(NSArray *)effectVariables
                    ;

- (void) clearShaders;
- (BOOL) linkShader:(NSError **)error;
- (void) parseUniforms;



@end

@implementation NPEffectTechnique

- (id) init
{
    return [ self initWithName:@"Technique" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    vertexShader = fragmentShader = nil;

    return self;
}

- (void) dealloc
{
    [ self clear ];
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
}

- (BOOL) loadFromStringList:(NPStringList *)stringList
                      error:(NSError **)error
{
    [ self clear ];

    NSAssert(parent != nil, @"Technique does not belong to an effect");

    NPParser * parser = [[ NPParser alloc ] init ];
    [ parser parse:stringList ];

    NSArray * effectVariableLines
        = [ self extractEffectVariableLines:stringList ];

    [ self parseShader:parser effectVariables:effectVariableLines ];

    glID = glCreateProgram();

    DESTROY(parser);

    if ( [ self linkShader:error ] == NO )
    {
        return NO;
    }

    [ self parseUniforms ];

    return YES;
}

@end

@implementation NPEffectTechnique (Private)

- (NPShader *) loadShaderFromFile:(NSString *)fileName
            insertEffectVariables:(NSArray *)effectVariables
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

    [ shaderSource insertStrings:effectVariables atIndex:0 ];

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
                 effectVariables:(NSArray *)effectVariables
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
                   effectVariables:(NSArray *)effectVariables
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

- (NSArray *) extractEffectVariableLines:(NPStringList *)stringList
{
    NSMutableArray * lines = [ NSMutableArray arrayWithCapacity:8 ];
    [ lines addObjectsFromArray:[ stringList stringsWithPrefix:@"uniform" ]];
    [ lines addObjectsFromArray:[ stringList stringsWithPrefix:@"varying" ]];

    return [ NSArray arrayWithArray:lines ];
}

- (void) parseVariables:(NPParser *)parser
{
    NSUInteger numberOfLines = [ parser lineCount ];
    for ( NSUInteger i = 0; i < numberOfLines; i++ )
    {

    }
}

- (void) parseShader:(NPParser *)parser
     effectVariables:(NSArray *)effectVariables
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

- (void) parseUniforms
{
	GLint numberOfActiveUniforms;
    GLint maxUniformNameLength;

	glGetProgramiv(glID, GL_ACTIVE_UNIFORMS, &numberOfActiveUniforms);
	glGetProgramiv(glID, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniformNameLength);

    NSLog(@"%d %d", numberOfActiveUniforms, maxUniformNameLength);

	for (int32_t i = 0; i < numberOfActiveUniforms; i++)
	{
		GLsizei uniformNameLength;
		GLint uniformSize;
		GLenum uniformType;
		char uniformName[maxUniformNameLength];

		glGetActiveUniform(glID, i, maxUniformNameLength, &uniformNameLength,
			&uniformSize, &uniformType, uniformName);

        NSLog(@"%s", uniformName);

		//string shaderVariableName(uniformName, uniformNameLength);

		// Sampler
		switch (uniformType)
		{
		case GL_SAMPLER_1D:
		case GL_SAMPLER_2D:
		case GL_SAMPLER_3D:
		//case GL_SAMPLER_1D_SHADOW:
		//case GL_SAMPLER_2D_SHADOW:
		case GL_SAMPLER_CUBE:
			{
                /*
				ZtShaderVariableTexture* variableTexture = getShaderVariableTexture(shaderVariableName);
				variableTexture->setGLID(i);
                */
				break;
			}

		case GL_SAMPLER_BUFFER_EXT:
			{
                /*
				if (ztTextureManager()->getTextureBufferSupport())
				{
					ZtShaderVariableTexture* variableTexture = getShaderVariableTexture(shaderVariableName);
					variableTexture->setGLID(i);
					break;
				}
                */

                break;
			}
		}

        /*
		// Semantics
		if (shaderVariableName.substr(0, 3) == "zt_")
		{
			ZtShaderVariableSemantic* variableSemantic = getShaderVariableSemantic(shaderVariableName);
			variableSemantic->setGLID(i);

			if (shaderVariableName == "zt_model"){variableSemantic->setSemanticType(MODEL_MATRIX);}
			if (shaderVariableName == "zt_inversemodel"){variableSemantic->setSemanticType(INVERSE_MODEL_MATRIX);}
			if (shaderVariableName == "zt_view"){variableSemantic->setSemanticType(VIEW_MATRIX);}
			if (shaderVariableName == "zt_inverseview"){variableSemantic->setSemanticType(INVERSE_VIEW_MATRIX);}
			if (shaderVariableName == "zt_projection"){variableSemantic->setSemanticType(PROJECTION_MATRIX);}
			if (shaderVariableName == "zt_inverseprojection"){variableSemantic->setSemanticType(INVERSE_PROJECTION_MATRIX);}
			if (shaderVariableName == "zt_modelview"){variableSemantic->setSemanticType(MODELVIEW_MATRIX);}
			if (shaderVariableName == "zt_inversemodelview"){variableSemantic->setSemanticType(INVERSE_MODELVIEW_MATRIX);}
			if (shaderVariableName == "zt_viewprojection"){variableSemantic->setSemanticType(VIEWPROJECTION_MATRIX);}
			if (shaderVariableName == "zt_inverseviewprojection"){variableSemantic->setSemanticType(INVERSE_VIEWPROJECTION_MATRIX);}
			if (shaderVariableName == "zt_modelviewprojection"){variableSemantic->setSemanticType(MODELVIEWPROJECTION_MATRIX);}
			if (shaderVariableName == "zt_inversemodelviewprojection"){variableSemantic->setSemanticType(INVERSE_MODELVIEWPROJECTION_MATRIX);}
		}
        */

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

@end

