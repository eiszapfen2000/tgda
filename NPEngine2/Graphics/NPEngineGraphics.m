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

    ilInit();
    iluInit();

    stringEnumConversion
        = [[ NPEngineGraphicsStringEnumConversion alloc ] 
                 initWithName:@"Graphics String Enum Conversion" ];

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
    GLenum error = glewInit();
    if ( error != GLEW_OK )
    {
        NSMutableDictionary * errorDetail = [ NSMutableDictionary dictionary ];
        NSString * errorString = [ NSString stringWithUTF8String:(const char *)glewGetErrorString(error) ];
        [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];

        NSError * error = [ NSError errorWithDomain:NPEngineErrorDomain 
                                               code:NPEngineGraphicsGLEWError
                                           userInfo:errorDetail ];
        NPLOG_ERROR(error);

        return NO;
    }

    return YES;
}

- (void) shutdown
{
}

- (BOOL) checkForGLError:(NSError **)error
{
    NSMutableDictionary * errorDetail = nil;
    NSString * errorString = nil;

    GLenum glError = glGetError();
    if( glError != GL_NO_ERROR )
    {
        if ( error != NULL )
        {
            errorDetail = [ NSMutableDictionary dictionary ];
            errorString = [ NSString stringWithUTF8String:(const char *)gluErrorString(glError) ];
            [ errorDetail setValue:errorString forKey:NSLocalizedDescriptionKey];
   
            *error = [ NSError errorWithDomain:NPEngineErrorDomain 
                                          code:NPEngineGraphicsGLError
                                      userInfo:errorDetail ];
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

