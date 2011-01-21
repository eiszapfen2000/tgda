#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import "GL/glew.h"
#import "GL/glu.h"
#import "Log/NPLog.h"
#import "Core/NPObject/NPObject.h"
#import "NPEngineGraphicsErrors.h"
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

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
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

- (void) setName:(NSString *)newName
{

}

- (id <NPPObject>) parent
{
    return nil;
}

- (void) setParent:(id <NPPObject>)newParent
{
}

- (uint32_t) objectID
{
    return objectID;
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

