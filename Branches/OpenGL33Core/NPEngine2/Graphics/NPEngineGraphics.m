#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import "GL/glew.h"
#import "GL/glu.h"
#import "IL/il.h"
#import "IL/ilu.h"
#import "Log/NPLog.h"
#import "Core/NPObject/NPObject.h"
#import "Core/String/NPStringList.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/Container/NPAssetArray.h"
#import "Image/NPImage.h"
#import "Texture/NPTexture2D.h"
#import "Texture/NPTexture3D.h"
#import "Texture/NPTextureBindingState.h"
#import "Texture/NPTextureSamplingState.h"
#import "Effect/NPShader.h"
#import "Effect/NPEffect.h"
#import "State/NPStateConfiguration.h"
#import "NPViewport.h"
#import "NPOrthographic.h"
#import "NPEngineGraphicsErrors.h"
#import "NPEngineGraphicsStringEnumConversion.h"
#import "NPEngineGraphicsStringToClassConversion.h"
#import "NPEngineGraphics.h"

static NSString * debug_source_to_string(GLenum debugSource)
{
    NSString * result = nil;
    switch (debugSource)
    {
        case GL_DEBUG_SOURCE_API_ARB:
        {
            result = @"OpenGL";
            break;
        }
 
        case GL_DEBUG_SOURCE_WINDOW_SYSTEM_ARB:
        {
            result = @"Window System";
            break;
        }

        case GL_DEBUG_SOURCE_SHADER_COMPILER_ARB:
        {
            result = @"Shader Compiler";
            break;
        }

        case GL_DEBUG_SOURCE_THIRD_PARTY_ARB:
        {
            result = @"Third Party";
            break;
        }

        case GL_DEBUG_SOURCE_APPLICATION_ARB:
        {
            result = @"Application";
            break;
        }

        case GL_DEBUG_SOURCE_OTHER_ARB:
        {
            result = @"Other";
            break;
        }

        default:
        {
            result = @"";
            break;
        }
    }

    return result;
}

static NSString * debug_type_to_string(GLenum debugType)
{
    NSString * result = nil;

    switch ( debugType )
    {
        case GL_DEBUG_TYPE_ERROR_ARB:
        {
            result = @"Error";
            break;
        }

        case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_ARB:
        {
            result = @"Deprecated Behavior";
            break;
        }

        case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_ARB:
        {
            result = @"Undefined Behavior";
            break;
        }

        case GL_DEBUG_TYPE_PORTABILITY_ARB:
        {
            result = @"Portability";
            break;
        }

        case GL_DEBUG_TYPE_PERFORMANCE_ARB:
        {
            result = @"Performance";
            break;
        }

        case GL_DEBUG_TYPE_OTHER_ARB:
        {
            result = @"Other";
            break;
        }

        default:
        {
            result = @"";
            break;
        }
    }

    return result;
}

static NSString * debug_severity_to_string(GLenum debugSeverity)
{
    NSString * result = nil;

    switch ( debugSeverity )
    {
        case GL_DEBUG_SEVERITY_HIGH_ARB:
        {
            result = @"High";
            break;
        }

        case GL_DEBUG_SEVERITY_MEDIUM_ARB:
        {
            result = @"Medium";
            break;
        }

        case GL_DEBUG_SEVERITY_LOW_ARB:
        {
            result = @"Low";
            break;
        }

        default:
        {
            result = @"None";
            break;
        }
    }

    return result;
}

static void GLAPIENTRY
debug_callback(GLenum source, GLenum type, GLuint mID, GLenum severity,
               GLsizei length, const GLchar* message, const GLvoid* userParam)
{
    NSString * sourceString = debug_source_to_string(source);
    NSString * typeString = debug_type_to_string(type);
    NSString * severityString = debug_severity_to_string(severity);

    NSString * messageString
        = [ NSString stringWithFormat:@"Source:%@ Type:%@ ID:%d Severity:%@ - %s",
                sourceString, typeString, mID, severityString, message ];

    [[ NPLog instance ] logMessage:messageString ];
}

static NPEngineGraphics * NP_ENGINE_GRAPHICS = nil;

@implementation NPEngineGraphics

+ (void) initialize
{
	if ( [ NPEngineGraphics class ] == self )
	{
		[[ self alloc ] init ];
	}
}

+ (NPEngineGraphics *) instance
{
    return NP_ENGINE_GRAPHICS;
}

+ (id) allocWithZone:(NSZone*)zone
{
    if ( self != [ NPEngineGraphics class ] )
    {
        [ NSException raise:NSInvalidArgumentException
	                 format:@"Illegal attempt to subclass NPEngineGraphics as %@", self ];
    }

    if ( NP_ENGINE_GRAPHICS == nil )
    {
        NP_ENGINE_GRAPHICS = [ super allocWithZone:zone ];
    }

    return NP_ENGINE_GRAPHICS;
}

- (id) init
{
    self = [ super init ];
    objectID = crc32_of_pointer(self);

    supportsSGIGenerateMipMap = NO;
    supportsAnisotropicTextureFilter = NO;
    supportsSamplerObjects = NO;
    coreContext = NO;
    debugContext = NO;

    maximumAnisotropy = 1;
    numberOfDrawBuffers = 1;
    numberOfColorAttachments = 0;
    maximalRenderbufferSize = 0;
    maximumDebugMessageLength = 0;

    ilInit();
    iluInit();

    stringEnumConversion
        = [[ NPEngineGraphicsStringEnumConversion alloc ] 
                 initWithName:@"Graphics String Enum Conversion" ];

    stringToClassConversion
        = [[ NPEngineGraphicsStringToClassConversion alloc ] 
                 initWithName:@"Graphics String To Class Conversion" ];

    images = [[ NPAssetArray alloc ]
                   initWithName:@"NP Engine Images"
                     assetClass:NSClassFromString(@"NPImage") ];

    textures2D = [[ NPAssetArray alloc ]
                       initWithName:@"NP Engine Textures2D"
                         assetClass:NSClassFromString(@"NPTexture2D") ];

    textures3D = [[ NPAssetArray alloc ]
                       initWithName:@"NP Engine Textures3D"
                         assetClass:NSClassFromString(@"NPTexture3D") ];

    effects = [[ NPAssetArray alloc ]
                    initWithName:@"NP Engine Shader"
                      assetClass:NSClassFromString(@"NPEffect") ];

    textureBindingState
        = [[ NPTextureBindingState alloc ]
                initWithName:@"NP Engine Texture Binding State" ];

    textureSamplingState
        = [[ NPTextureSamplingState alloc ]
                initWithName:@"NP Engine Texture Sampling State" ];

    stateConfiguration
        = [[ NPStateConfiguration alloc ]
                initWithName:@"NP Engine State Configuration" ];

    viewport
        = [[ NPViewport alloc ] initWithName:@"NP Engine Viewport" ];

    orthographic
        = [[ NPOrthographic alloc ] initWithName:@"NP Engine Orthographic Rendering" ];

    return self;
}

- (void) dealloc
{
    ilShutDown();

    DESTROY(orthographic);
    DESTROY(viewport);
    DESTROY(stateConfiguration);
    DESTROY(textureBindingState);
    DESTROY(textureSamplingState);

    DESTROY(effects);
    DESTROY(textures3D);
    DESTROY(textures2D);
    DESTROY(images);

    DESTROY(stringToClassConversion);
    DESTROY(stringEnumConversion);

    [ super dealloc ];
}

- (NPEngineGraphicsStringEnumConversion *) stringEnumConversion
{
    return stringEnumConversion;
}

- (NPEngineGraphicsStringToClassConversion *) stringToClassConversion
{
    return stringToClassConversion;
}

- (NPAssetArray *) images
{
    return images;
}

- (NPAssetArray *) textures2D
{
    return textures2D;
}

- (NPAssetArray *) textures3D
{
    return textures3D;
}

- (NPAssetArray *) effects
{
    return effects;
}

- (NPTextureBindingState *) textureBindingState
{
    return textureBindingState;
}

- (NPTextureSamplingState *) textureSamplingState
{
    return textureSamplingState;
}

- (NPStateConfiguration *) stateConfiguration
{
    return stateConfiguration;
}

- (NPViewport *) viewport
{
    return viewport;
}

- (NPOrthographic *) orthographic
{
    return orthographic;
}

- (BOOL) startup
{
    NPLOG(@"");
    NPLOG(@"%@ starting up...", [ self name ]);

    glewExperimental = GL_TRUE;
    GLenum glewInitError = glewInit();
    if ( glewInitError != GLEW_OK )
    {
        NSString * errorString
            = [ NSString stringWithUTF8String:(const char *)glewGetErrorString(glewInitError) ];

        NSError * error = [ NSError errorWithCode:NPEngineGraphicsGLEWError
                                      description:errorString ];

        NPLOG_ERROR(error);

        return NO;
    }

    [ self checkForGLErrors ];

    if ( !GLEW_VERSION_3_1 )
    {
        NSString * errorString = @"Your system does not support OpenGL 3.1.";
        NSError * error = [ NSError errorWithCode:NPEngineGraphicsGLEWError
                                      description:errorString ];

        NPLOG_ERROR(error);
        return NO;
    }

    if ( GLEW_VERSION_3_2 )
    {
        GLint profileMask = 0;
        glGetIntegerv(GL_CONTEXT_PROFILE_MASK, &profileMask);

        if ( profileMask & GL_CONTEXT_CORE_PROFILE_BIT )
        {
            coreContext = YES;
            NPLOG(@"Core Context Enabled");
        }
    }

    if ( GLEW_ARB_debug_output )
    {
        debugContext = YES;

        glGetIntegerv(GL_MAX_DEBUG_MESSAGE_LENGTH_ARB, &maximumDebugMessageLength);
        // register debug callback
        glDebugMessageCallbackARB(&debug_callback, NULL);
        // enable ALL debug messages
        glDebugMessageControlARB(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, NULL, GL_TRUE);

        NPLOG(@"Debug Context Enabled");
    }

    glGetIntegerv(GL_MAX_DRAW_BUFFERS, &numberOfDrawBuffers);
    NPLOG(@"Draw Buffers: %d", numberOfDrawBuffers);

    if ( GLEW_SGIS_generate_mipmap )
    {
        supportsSGIGenerateMipMap = YES;
        NPLOG(@"GL_SGIS_generate_mipmap supported");
    }

    if ( GLEW_EXT_texture_filter_anisotropic )
    {
        supportsAnisotropicTextureFilter = YES;
        glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &maximumAnisotropy);
        NPLOG(@"GL_EXT_texture_filter_anisotropic with maximum anisotropy %d supported", maximumAnisotropy);
    }

    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &numberOfColorAttachments);
    glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE, &maximalRenderbufferSize);

    NPLOG(@"Color Attachments: %d", numberOfColorAttachments);
    NPLOG(@"Renderbuffer resolution up to: %d", maximalRenderbufferSize);

    [ textureBindingState startup ];

    if ( GLEW_ARB_sampler_objects )
    {
        supportsSamplerObjects = YES;
        NPLOG(@"GL_ARB_sampler_objects supported");

        [ textureSamplingState startup ];
    }

    NPLOG(@"%@ started\n", [ self name ]);

    [ stateConfiguration setCoreProfileOnly:coreContext ];
    [ stateConfiguration activate ];

    return YES;
}

- (void) shutdown
{
    [ textureBindingState  shutdown ];
    [ textureSamplingState shutdown ];
}

- (BOOL) supportsSGIGenerateMipMap
{
    return supportsSGIGenerateMipMap;
}

- (BOOL) supportsAnisotropicTextureFilter
{
    return supportsAnisotropicTextureFilter;
}

- (BOOL) supportsSamplerObjects
{
    return supportsSamplerObjects;
}

- (BOOL) coreContext
{
    return coreContext;
}

- (BOOL) debugContext
{
    return debugContext;
}

- (int32_t) maximumAnisotropy
{
    return maximumAnisotropy;
}

- (int32_t) numberOfDrawBuffers
{
    return numberOfDrawBuffers;
}

- (int32_t) numberOfColorAttachments
{
    return numberOfColorAttachments;
}

- (int32_t) maximalRenderbufferSize
{
    return maximalRenderbufferSize;
}

- (int32_t) maximumDebugMessageLength
{
    return maximumDebugMessageLength;
}

- (void) checkForDebugMessages
{
    if ( debugContext == YES )
    {
        GLint n = 0;
        glGetIntegerv(GL_DEBUG_LOGGED_MESSAGES_ARB, &n);

        GLenum source;
        GLenum type;
        GLenum messageID;
        GLenum severity;
        GLsizei length;        

        while ( n != 0 )
        {
            GLint s = 0;
            glGetIntegerv(GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH_ARB, &s);

            GLchar logBuffer[maximumDebugMessageLength];
            GLuint i
                = glGetDebugMessageLogARB(1, maximumDebugMessageLength, &source,
                                &type, &messageID, &severity, &length, logBuffer);

            if ( i != 0 )
            {
                NSString * sourceString = debug_source_to_string(source);
                NSString * typeString = debug_type_to_string(type);
                NSString * severityString = debug_severity_to_string(severity);

                NPLOG(@"Source:%@ Type:%@ ID:%d Severity:%@ - %s", sourceString,
                      typeString, messageID, severityString, logBuffer);
            }

            glGetIntegerv(GL_DEBUG_LOGGED_MESSAGES_ARB, &n);
        }
    }
}

- (BOOL) checkForGLError:(NSError **)error
{
    GLenum glError = glGetError();
    if( glError != GL_NO_ERROR )
    {
        if ( error != NULL )
        {
            NSString * errorString
                = [ NSString stringWithCString:(const char *)gluErrorString(glError)
                                      encoding:NSASCIIStringEncoding ];

            *error = [ NSError errorWithCode:NPEngineGraphicsGLError
                                 description:errorString ];
        }

        return NO;
    }

    return YES;
}

- (void) checkForGLErrors
{
    NSError * error = nil;
    while ( [ self checkForGLError:&error ] == NO )
    {
        NPLOG_ERROR(error);
        error = nil;
    }    
}

- (void) clearFrameBuffer:(BOOL)clearFrameBuffer
              depthBuffer:(BOOL)clearDepthBuffer
            stencilBuffer:(BOOL)clearStencilBuffer
{
    GLbitfield buffersToClear = 0;

    if ( clearFrameBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_COLOR_BUFFER_BIT;
    }

    if ( clearDepthBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_DEPTH_BUFFER_BIT;
    }

    if ( clearStencilBuffer == YES )
    {
        buffersToClear = buffersToClear | GL_STENCIL_BUFFER_BIT;
    }

    glClear(buffersToClear);
}

- (void) clearDrawBuffer:(int32_t)drawbuffer
                   color:(FVector4)color
{
    NSAssert(drawbuffer < numberOfDrawBuffers, @"");

    const float c[4] = {color.x, color.y, color.z, color.w};
    glClearBufferfv(GL_COLOR, drawbuffer, c);
}

- (void) clearDepthBuffer:(float)depth
{
    glClearBufferfv(GL_DEPTH, 0, &depth);
}

- (void) clearStencilBuffer:(int32_t)stencil
{
    glClearBufferiv(GL_STENCIL, 0, &stencil);
}

- (void) clearDepthBuffer:(float)depth
            stencilBuffer:(int32_t)stencil
{
    glClearBufferfi(GL_DEPTH_STENCIL, 0, depth, stencil);
}

- (NSString *) name
{
    return @"NPEngine Graphics";
}

- (uint32_t) objectID
{
    return objectID;
}

- (void) setName:(NSString *)newName
{
}

- (void) setObjectID:(uint32_t)newObjectID
{
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return ULONG_MAX;
} 

- (oneway void) release
{
} 

- (id) autorelease
{
    return self;
}

@end

