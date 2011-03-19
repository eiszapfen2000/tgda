#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import "GL/glew.h"
#import "GL/glu.h"
#import "IL/il.h"
#import "IL/ilu.h"
#import "Log/NPLog.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/Container/NPAssetArray.h"
#import "Image/NPImage.h"
#import "Texture/NPTexture2D.h"
#import "Effect/NPShader.h"
#import "Effect/NPEffect.h"
#import "State/NPStateConfiguration.h"
#import "NPEngineGraphicsErrors.h"
#import "NPEngineGraphicsStringEnumConversion.h"
#import "NPEngineGraphicsStringToClassConversion.h"
#import "NPEngineGraphics.h"

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
    maximumAnisotropy = 1;
    supportssRGBTextures = NO;
    supportsEXTFBO = NO;
    supportsARBFBO = NO;

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

    effects = [[ NPAssetArray alloc ]
                    initWithName:@"NP Engine Shader"
                      assetClass:NSClassFromString(@"NPEffect") ];

    stateConfiguration
        = [[ NPStateConfiguration alloc ]
                initWithName:@"NP Engine State Configuration" ];

    return self;
}

- (void) dealloc
{
    ilShutDown();

    DESTROY(stateConfiguration);

    DESTROY(effects);
    DESTROY(textures2D);
    DESTROY(images);

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

- (NPAssetArray *) effects
{
    return effects;
}

- (NPStateConfiguration *) stateConfiguration
{
    return stateConfiguration;
}

- (BOOL) startup
{
    NPLOG(@"%@ starting up...", [ self name ]);

    GLenum error = glewInit();
    if ( error != GLEW_OK )
    {
        NSString * errorString
            = [ NSString stringWithUTF8String:(const char *)glewGetErrorString(error) ];

        NSError * error = [ NSError errorWithCode:NPEngineGraphicsGLEWError
                                      description:errorString ];

        NPLOG_ERROR(error);

        return NO;
    }

    if ( !GLEW_VERSION_2_0 )
    {
        NSString * errorString = @"Your system does not support OpenGL 2.0.";
        NSError * error = [ NSError errorWithCode:NPEngineGraphicsGLEWError
                                      description:errorString ];

        NPLOG_ERROR(error);
        return NO;
    }

    if ( GL_SGIS_generate_mipmap )
    {
        supportsSGIGenerateMipMap = YES;
        NPLOG(@"GL_SGIS_generate_mipmap supported");
    }

    if ( GLEW_EXT_texture_filter_anisotropic )
    {
        supportsAnisotropicTextureFilter = YES;
        glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT,&maximumAnisotropy);
        NPLOG(@"GL_EXT_texture_filter_anisotropic with maximum anisotropy %d supported", maximumAnisotropy);
    }

    if ( GL_EXT_texture_sRGB || GLEW_VERSION_2_1 )
    {
        supportssRGBTextures = YES;
        NPLOG(@"GL_EXT_texture_sRGB supported");
    }

    if ( GLEW_EXT_framebuffer_object )
    {
        supportsEXTFBO = YES;
        NPLOG(@"GL_EXT_framebuffer_object supported");
    }

    if ( GLEW_ARB_framebuffer_object )
    {
        supportsARBFBO = YES;
        NPLOG(@"GL_ARB_framebuffer_object supported");
    }

    NPLOG(@"%@ started", [ self name ]);

    return YES;
}

- (void) shutdown
{
}

- (BOOL) supportsSGIGenerateMipMap
{
    return supportsSGIGenerateMipMap;
}

- (BOOL) supportsAnisotropicTextureFilter
{
    return supportsAnisotropicTextureFilter;
}

- (int32_t) maximumAnisotropy
{
    return maximumAnisotropy;
}

- (BOOL) supportssRGBTextures
{
    return supportssRGBTextures;
}

- (BOOL) supportsEXTFBO
{
    return supportsEXTFBO;
}

- (BOOL) supportsARBFBO
{
    return supportsARBFBO;
}

- (BOOL) checkForGLError:(NSError **)error
{
    GLenum glError = glGetError();
    if( glError != GL_NO_ERROR )
    {
        if ( error != NULL )
        {
            NSString * errorString
                = [ NSString stringWithUTF8String:(const char *)gluErrorString(glError) ];

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

- (void) update
{
}

- (void) render
{
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

- (void) release
{
} 

- (id) autorelease
{
    return self;
}


@end

