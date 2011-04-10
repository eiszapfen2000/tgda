#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPBufferObject.h"

@interface NPBufferObject (Private)

- (void) deleteBuffer;
- (BOOL) createBuffer:(NSData *)data
                error:(NSError**)error
                     ;

@end

@implementation NPBufferObject (Private)

- (void) deleteBuffer
{
    if ( glID > 0 )
    {
        glDeleteBuffers(1, &glID);
        glID = 0;
    }
}

- (BOOL) createBuffer:(NSData *)data
                error:(NSError**)error
{
    [ self deleteBuffer ];

    glGenBuffers(1, &glID);
    glTarget = getGLBufferType(type);

    GLenum bufferUsage = getGLBufferUsage(updateRate, dataUsage);

    glBindBuffer(glTarget, glID);
    glBufferData(glTarget, [ data length ], [ data bytes ], bufferUsage);
    glBindBuffer(glTarget, 0);

    return YES;
}

@end

@implementation NPBufferObject

- (id) init
{
    return [ self initWithName:@"Buffer Object" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glID = 0;
    glTarget = GL_NONE;
    type = NpBufferObjectTypeUnknown;

    return self;
}

- (void) dealloc
{
    [ self deleteBuffer ];
    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (BOOL) generate:(NpBufferObjectType)newType
       updateRate:(NpBufferDataUpdateRate)newUpdateRate
        dataUsage:(NpBufferDataUsage)newDataUsage
             data:(NSData *)newData
            error:(NSError **)error
{
    type = newType;
    updateRate = newUpdateRate;
    dataUsage = newDataUsage;

    return YES;
}

- (void) activate
{
    glBindBuffer(glTarget, glID);
}

- (void) deactivate
{
    glBindBuffer(glTarget, 0);
}

@end
